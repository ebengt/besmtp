defmodule BesmtpTest do
  # No :async since environemnt variables are used in "mailman_context" and "mailman_context/port" .
  use ExUnit.Case

  doctest Besmtp

  setup_all do
    Mailman.TestServer.start()
    {:ok, :ok}
  end

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
    System.delete_env("password")
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

  test "mailman_context/password" do
    relay = "asdqwe"
    System.put_env("smtp", relay)
    user = "kalle"
    System.put_env("from", user)
    password = "gustav"
    System.put_env("password", password)
    mc = Besmtp.mailman_context()
    assert mc.config.relay === relay
    assert mc.config.port === 587
    assert mc.config.auth === :always
    assert mc.config.username === user
    assert mc.config.password === password
  end

  test "mailman_context/password/port" do
    relay = "asdqwe"
    port = 123
    System.put_env("smtp", relay <> ":#{port}")
    user = "kalle"
    System.put_env("from", user)
    password = "gustav"
    System.put_env("password", password)
    mc = Besmtp.mailman_context()
    assert mc.config.relay === relay
    assert mc.config.port === port
    assert mc.config.auth === :always
    assert mc.config.username === user
    assert mc.config.password === password
  end

  test "mailman_email" do
    to = "kalle"
    subject = "aboutit"
    text = "text message"
    from = "somebody"
    System.put_env("from", from)
    me = Besmtp.mailman_email({to, subject, text})
    assert me.to === [to]
    assert me.subject === subject
    assert me.text === text
    assert me.from === from
    assert me.reply_to === from
  end

  test "deliver" do
    to = "kalle"
    subject = "aboutit"
    text = "text message"
    from = "somebody"
    System.put_env("from", from)
    me = Besmtp.mailman_email({to, subject, text})
    mc = %Mailman.Context{config: %Mailman.TestConfig{}}
    {:ok, md} = Besmtp.mailman_deliver(me, mc)
    assert String.contains?(md, "From: " <> from)
    assert String.contains?(md, "Subject: " <> subject)
    assert String.contains?(md, "\r\n\r\n" <> text)
  end
end
