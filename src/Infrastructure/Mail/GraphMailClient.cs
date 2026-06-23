namespace QuotationAccelerator.Infrastructure.Mail;

using Microsoft.Graph;
using Microsoft.Graph.Models;
using Microsoft.Graph.Users.Item.Messages.Item.Reply;
using Microsoft.Graph.Users.Item.SendMail;
using Microsoft.Identity.Client;
using Microsoft.Kiota.Abstractions.Authentication;
using QuotationAccelerator.Catalog.Application.Abstractions;
using QuotationAccelerator.Inbox.Application.Abstractions;
using QuotationAccelerator.SharedKernel.Results;

public sealed class GraphMailClient(
    IMailAccountRepository accountRepository,
    IAppPathProvider appPathProvider) : IMailClient
{
    private static readonly string[] Scopes =
    [
        "Mail.Read.Shared",
        "Mail.Send.Shared",
        "User.Read",
        "offline_access",
    ];

    private IPublicClientApplication? _publicClient;
    private GraphServiceClient? _graphClient;
    private string? _mailboxAddress;

    public bool IsConnected => _graphClient is not null;

    public async Task<Result> ConnectInteractiveAsync(CancellationToken cancellationToken)
    {
        if (IsConnected)
        {
            return Result.Success();
        }

        var settings = await accountRepository.GetSettingsAsync(cancellationToken);
        if (!settings.IsConfigured)
        {
            return Result.Failure("Mail account settings are incomplete.");
        }

        try
        {
            _publicClient = PublicClientApplicationBuilder
                .Create(settings.ClientId!)
                .WithAuthority(AzureCloudInstance.AzurePublic, settings.TenantId!)
                .WithRedirectUri("http://localhost")
                .Build();

            MailTokenCacheHelper.Register(_publicClient, appPathProvider.GetApplicationDirectory());

            var account = (await _publicClient.GetAccountsAsync()).FirstOrDefault();
            AuthenticationResult authResult;

            try
            {
                authResult = await _publicClient.AcquireTokenSilent(Scopes, account).ExecuteAsync(cancellationToken);
            }
            catch (MsalUiRequiredException)
            {
                authResult = await _publicClient.AcquireTokenInteractive(Scopes).ExecuteAsync(cancellationToken);
            }

            _mailboxAddress = settings.MailboxAddress!;
            _graphClient = CreateGraphClient(authResult.AccessToken);
            return Result.Success();
        }
        catch (Exception ex)
        {
            return Result.Failure($"Mail sign-in failed: {ex.Message}");
        }
    }

    public Task DisconnectAsync(CancellationToken cancellationToken)
    {
        _graphClient = null;
        _mailboxAddress = null;
        return Task.CompletedTask;
    }

    public async Task<Result<IReadOnlyList<RemoteMailMessage>>> FetchMessagesAsync(
        DateTimeOffset? since,
        CancellationToken cancellationToken)
    {
        if (_graphClient is null || string.IsNullOrWhiteSpace(_mailboxAddress))
        {
            return Result<IReadOnlyList<RemoteMailMessage>>.Failure("Mail account is not connected.");
        }

        try
        {
            var settings = await accountRepository.GetSettingsAsync(cancellationToken);
            var folderName = string.IsNullOrWhiteSpace(settings.FolderName) ? "Inbox" : settings.FolderName;

            var messages = await _graphClient.Users[_mailboxAddress]
                .MailFolders[folderName]
                .Messages
                .GetAsync(request =>
                {
                    request.QueryParameters.Top = 25;
                    request.QueryParameters.Orderby = ["receivedDateTime desc"];
                    request.QueryParameters.Select =
                    [
                        "id",
                        "subject",
                        "from",
                        "receivedDateTime",
                        "bodyPreview",
                        "body",
                        "hasAttachments",
                    ];

                    if (since.HasValue)
                    {
                        request.QueryParameters.Filter =
                            $"receivedDateTime ge {since.Value.UtcDateTime:yyyy-MM-ddTHH:mm:ssZ}";
                    }
                }, cancellationToken);

            var result = new List<RemoteMailMessage>();
            foreach (var message in messages?.Value ?? [])
            {
                if (string.IsNullOrWhiteSpace(message.Id))
                {
                    continue;
                }

                var attachments = new List<RemoteMailAttachment>();
                if (message.HasAttachments == true)
                {
                    var attachmentResponse = await _graphClient.Users[_mailboxAddress]
                        .Messages[message.Id]
                        .Attachments
                        .GetAsync(cancellationToken: cancellationToken);

                    foreach (var attachment in attachmentResponse?.Value ?? [])
                    {
                        if (attachment is FileAttachment fileAttachment
                            && !string.IsNullOrWhiteSpace(fileAttachment.Name)
                            && !string.IsNullOrWhiteSpace(fileAttachment.Id))
                        {
                            attachments.Add(new RemoteMailAttachment
                            {
                                Id = fileAttachment.Id,
                                FileName = fileAttachment.Name,
                                ContentType = fileAttachment.ContentType,
                            });
                        }
                    }
                }

                result.Add(new RemoteMailMessage
                {
                    GraphMessageId = message.Id,
                    Subject = message.Subject ?? "(no subject)",
                    FromAddress = message.From?.EmailAddress?.Address ?? "unknown@unknown",
                    FromDisplayName = message.From?.EmailAddress?.Name,
                    ReceivedAt = message.ReceivedDateTime ?? DateTimeOffset.UtcNow,
                    BodyPreview = message.BodyPreview,
                    BodyText = message.Body?.ContentType == BodyType.Text
                        ? message.Body.Content
                        : message.BodyPreview,
                    Attachments = attachments,
                });
            }

            return Result<IReadOnlyList<RemoteMailMessage>>.Success(result);
        }
        catch (Exception ex)
        {
            return Result<IReadOnlyList<RemoteMailMessage>>.Failure($"Failed to fetch messages: {ex.Message}");
        }
    }

    public async Task<Result<byte[]>> DownloadAttachmentAsync(
        string graphMessageId,
        string attachmentId,
        CancellationToken cancellationToken)
    {
        if (_graphClient is null || string.IsNullOrWhiteSpace(_mailboxAddress))
        {
            return Result<byte[]>.Failure("Mail account is not connected.");
        }

        try
        {
            var attachment = await _graphClient.Users[_mailboxAddress]
                .Messages[graphMessageId]
                .Attachments[attachmentId]
                .GetAsync(cancellationToken: cancellationToken);

            if (attachment is not FileAttachment fileAttachment || fileAttachment.ContentBytes is null)
            {
                return Result<byte[]>.Failure("Attachment content is not available.");
            }

            return Result<byte[]>.Success(fileAttachment.ContentBytes);
        }
        catch (Exception ex)
        {
            return Result<byte[]>.Failure($"Failed to download attachment: {ex.Message}");
        }
    }

    public async Task<Result> SendReplyAsync(
        string graphMessageId,
        string toAddress,
        string subject,
        string body,
        IReadOnlyList<MailAttachmentPayload>? attachments,
        CancellationToken cancellationToken)
    {
        if (_graphClient is null || string.IsNullOrWhiteSpace(_mailboxAddress))
        {
            return Result.Failure("Mail account is not connected.");
        }

        try
        {
            var message = new Message
            {
                Subject = subject,
                Body = new ItemBody
                {
                    ContentType = BodyType.Text,
                    Content = body,
                },
                ToRecipients =
                [
                    new Recipient
                    {
                        EmailAddress = new EmailAddress
                        {
                            Address = toAddress,
                        },
                    },
                ],
            };

            if (attachments is { Count: > 0 })
            {
                message.Attachments = attachments.Select(attachment => new FileAttachment
                {
                    OdataType = "#microsoft.graph.fileAttachment",
                    Name = attachment.FileName,
                    ContentType = attachment.ContentType,
                    ContentBytes = attachment.Content,
                }).Cast<Attachment>().ToList();
            }

            if (attachments is null || attachments.Count == 0)
            {
                await _graphClient.Users[_mailboxAddress]
                    .Messages[graphMessageId]
                    .Reply
                    .PostAsync(new ReplyPostRequestBody
                    {
                        Message = new Message
                        {
                            Body = message.Body,
                        },
                    }, cancellationToken: cancellationToken);
            }
            else
            {
                await _graphClient.Users[_mailboxAddress]
                    .SendMail
                    .PostAsync(new SendMailPostRequestBody
                    {
                        Message = message,
                        SaveToSentItems = true,
                    }, cancellationToken: cancellationToken);
            }

            return Result.Success();
        }
        catch (Exception ex)
        {
            return Result.Failure($"Failed to send mail: {ex.Message}");
        }
    }

    private static GraphServiceClient CreateGraphClient(string accessToken)
    {
        var provider = new BaseBearerTokenAuthenticationProvider(new StaticAccessTokenProvider(accessToken));
        return new GraphServiceClient(provider);
    }

    private sealed class StaticAccessTokenProvider(string accessToken) : IAccessTokenProvider
    {
        public AllowedHostsValidator AllowedHostsValidator { get; } = new();

        public Task<string> GetAuthorizationTokenAsync(
            Uri uri,
            Dictionary<string, object>? additionalAuthenticationContext = null,
            CancellationToken cancellationToken = default) =>
            Task.FromResult(accessToken);
    }
}
