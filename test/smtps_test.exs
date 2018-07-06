defmodule BesmtpTest do
  # No :async since environemnt variables are used in "mailman_context" and "mailman_context/port" .
  use ExUnit.Case

  doctest Besmtp

  test "arguments/help" do
    :help = Besmtp.arguments(["--help"])
  end

  test "arguments/error" do
    :help = Besmtp.arguments(["--unknown"])
  end

  test "arguments" do
    to = "kalle"
    subject = "asd"
    infile = "qwe"
    {^to, ^subject, ^infile} = Besmtp.arguments(["--infile", infile, "--subject", subject, to])
  end

  test "mailman_context" do
    relay = "asdqwe"
    System.put_env("smtp", relay)
    mc = Besmtp.mailman_context()
    assert mc.config.relay === relay
    assert mc.config.port === 25
    assert mc.config.auth === :never
  end

  test "mailman_context/port" do
    relay = "asdqwe"
    port = 123
    System.put_env("smtp", relay <> ":#{port}")
    mc = Besmtp.mailman_context()
    assert mc.config.relay === relay
    assert mc.config.port === port
    assert mc.config.auth === :never
  end

  test "mailman_email" do
    from = "somebody"
    to = "kalle"
    subject = "aboutit"
    text = "text message"
    System.put_env("from", from)
    me = Besmtp.mailman_email({to, subject, text})
    assert me.to === [to]
    assert me.subject === subject
    assert me.text === text
    assert me.from === from
    assert me.reply_to === from
  end
end
