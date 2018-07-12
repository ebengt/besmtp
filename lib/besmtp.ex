defmodule Besmtp do
  @moduledoc """
    [--help] --infile file --subject subject receiver

  Send file to receiver with subject.
  Pretend to be from environment variable $from.
  Use SMTP server from environemnt variable $smtp.
  If there is a $password, use TLS to authenticate.
  """

  def arguments(argv) do
    OptionParser.parse(argv, switches: [help: :boolean, infile: :string, subject: :string])
    |> arguments_private
  end

  def mailman_deliver(email, context), do: Mailman.deliver(email, context)

  def mailman_context do
    f = System.get_env("from")
    p = System.get_env("password")

    {r, port} = System.get_env("smtp") |> String.split(":") |> mailman_context_relay_port(p)

    %Mailman.Context{
      config: %Mailman.SmtpConfig{
        relay: r,
        username: f,
        password: p,
        port: port,
        auth: mailman_context_auth(p),
        tls: mailman_context_tls(p)
      }
    }
  end

  def mailman_email({to, subject, text}) do
    from = System.get_env("from")

    %Mailman.Email{
      subject: subject,
      from: from,
      reply_to: from,
      to: [to],
      text: text
    }
  end

  def main(argv), do: argv |> arguments |> main_private

  # Private functions

  defp arguments_private({parsed, argv, errors}) do
    help = arguments_private_help(Keyword.fetch(parsed, :help), errors, argv)
    arguments_private(help, parsed, argv)
  end

  defp arguments_private(:nohelp, parsed, [to]) do
    subject = Keyword.fetch!(parsed, :subject)
    infile = Keyword.fetch!(parsed, :infile)
    {to, subject, infile}
  end

  defp arguments_private(:help, _parsed, _argv), do: :help

  defp arguments_private_help(:error, [], [_to]), do: :nohelp
  defp arguments_private_help(_help, _errors, _argv), do: :help

  defp mailman_context_auth(nil), do: :never
  defp mailman_context_auth(_password), do: :always

  defp mailman_context_relay_port([relay], nil), do: {relay, 25}
  defp mailman_context_relay_port([relay], _password), do: {relay, 587}
  defp mailman_context_relay_port([relay, port], _), do: {relay, String.to_integer(port)}

  defp mailman_context_tls(nil), do: :never
  defp mailman_context_tls(_password), do: :always

  defp main_private(:help), do: usage()

  defp main_private(args),
    do: args |> read_infile |> mailman_email |> main_private_deliver

  defp main_private_deliver(email) do
    {:ok, d} = mailman_deliver(email, mailman_context())

    # Mailman.Email.parse! => :load_failed, 'Failed to load NIF library: \'priv/eiconv_nif.so: cannot open shared object file: No such file or directory\''
    # email = Mailman.Email.parse!(d)
    # email.delivery for Date:
    [header | _] = String.split(d, "\r\n\r\n")
    main_private_deliver_ok(String.contains?(header, "\r\nDate: "))
  end

  defp main_private_deliver_ok(true), do: System.stop(0)
  defp main_private_deliver_ok(false), do: System.stop(1)

  defp read_infile({to, subject, infile}), do: {to, subject, File.read!(infile)}

  defp usage, do: IO.puts("#{:escript.script_name()}" <> @moduledoc)
end
