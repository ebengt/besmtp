defmodule Besmtp do
  @moduledoc """
  [--help] --infile file --subject subject receiver

Send file to receiver with subject.
Pretend to be from environment variable $from.
Use SMTP server from environemnt variable $smtp.
"""

	def arguments argv do
		(OptionParser.parse argv, switches: [help: :boolean, infile: :string, subject: :string]) |> arguments_private
	end

	def mailman_context do
		{relay, port} = (System.get_env "smtp") |> (String.split ":") |> mailman_context_relay_port
		%Mailman.Context{config: %Mailman.SmtpConfig{relay: relay,
			  port: port,
			  auth: :never}
			  }
	end

	def mailman_email {to, subject, text} do
		from = System.get_env "from"
		%Mailman.Email{
			subject: subject,
      			from: from,
      			reply_to: from,
      			to: [to],
      			text: text
		}
	end

	def main( argv ), do: (arguments argv) |> main_private

	# Private functions

	defp arguments_private( {parsed, argv, errors} ) do
		help = arguments_private_help (Keyword.fetch parsed, :help), errors, argv
		arguments_private_nohelp help, parsed, argv
	end
	defp arguments_private_help( :error, [], [_to] ), do: :nohelp
	defp arguments_private_help( _help, _errors, _argv ), do: :help
	defp arguments_private_nohelp :nohelp, parsed, [to] do
		subject = Keyword.fetch! parsed, :subject
		infile = Keyword.fetch! parsed, :infile
		{to, subject, infile}
	end
	defp arguments_private_nohelp( :help, _parsed, _argv ), do: :help

	defp mailman_context_relay_port( [relay] ), do: {relay, 25}
	defp mailman_context_relay_port( [relay, port] ), do: {relay, String.to_integer(port)}

	defp main_private( :help ), do: usage()
	defp main_private( args ), do: (read_infile args) |> mailman_email |> (Mailman.deliver mailman_context())

	defp read_infile( {to, subject, infile} ), do: {to, subject, (File.read! infile)}

	defp usage, do: IO.puts "#{:escript.script_name}" <> @moduledoc

end
