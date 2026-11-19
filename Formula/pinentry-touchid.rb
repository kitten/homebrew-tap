class PinentryTouchid < Formula
  desc "Touch ID pinentry for GnuPG on macOS"
  homepage "https://github.com/kitten/pinentry-touchid"
  url "https://github.com/kitten/pinentry-touchid/releases/download/v0.1.7/pinentry-touchid-macos.zip"
  version "0.1.7"
  sha256 "a533145f89e4a87991c1517c4e0e5d43dc9977881475a3d2661fc1f6508f2e06"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "pinentry"
  depends_on "pinentry-mac"

  # Preserve the Developer ID signature, provisioning profile and bundle layout.
  def install
    libexec.install "pinentry-touchid.app"
    (bin/"pinentry-touchid").write_env_script libexec/"pinentry-touchid.app/Contents/MacOS/pinentry-touchid",
      PATH: "#{formula_opt_bin("pinentry-mac")}:#{formula_opt_bin("pinentry")}:$PATH"
  end

  def caveats
    <<~EOS
      To select this pinentry, set the following in ~/.gnupg/gpg-agent.conf:
        pinentry-program #{opt_bin}/pinentry-touchid
      Then reload the agent with: gpg-connect-agent reloadagent /bye
      Touch ID requires an active, unlocked graphical session; otherwise
      pinentry-curses is used. Installation does not change GnuPG configuration.
    EOS
  end

  test do
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", libexec/"pinentry-touchid.app"
    output = pipe_output("#{bin}/pinentry-touchid -tty", "GETINFO version\nBYE\n", 0)
    assert_match(/D \d+\./, output)
    assert_match "OK", output
  end
end
