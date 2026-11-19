class GitPorter < Formula
  desc "Guarded Git handoff between your laptop and an agent box"
  homepage "https://github.com/kitten/git-porter"
  license "MIT"

  uses_from_macos "git"
  uses_from_macos "openssh"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.0/git-porter-0.1.0-macos-arm64.tar.gz"
      sha256 "c580486ba15ae88479fe2f9dc0e4fcb27094cd27896d87eb0d4af239082c0ad2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.0/git-porter-0.1.0-linux-arm64.tar.gz"
      sha256 "42d7a1e13592707240784f18ceb6615a8701dd6f4e9e703711a91d7fc3e2a678"
    end
    on_intel do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.0/git-porter-0.1.0-linux-x86_64.tar.gz"
      sha256 "ad16e2024ab05a52493df1f27f399585d4463936a9a6ffdaae2705612e9d75fb"
    end
  end

  def install
    bin.install "git-porter", "git-send", "git-receive"
    doc.install "README.md"
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    ENV["XDG_DATA_HOME"] = testpath/"data"
    ENV["XDG_CACHE_HOME"] = testpath/"cache"
    ENV["XDG_STATE_HOME"] = testpath/"state"
    ENV["XDG_RUNTIME_DIR"] = testpath/"run"
    (testpath/"run").mkpath
    (testpath/"run").chmod 0700
    ENV["GIT_CONFIG_NOSYSTEM"] = "1"
    ENV["GIT_CONFIG_GLOBAL"] = File::NULL
    system "git", "init", "--initial-branch=main"
    assert_match version.to_s, shell_output("#{bin}/git-porter --version")
    assert_match "No such file or directory", shell_output("#{bin}/git-porter key:public 2>&1", 1)
    %w[git-send git-receive].each do |command|
      assert_match "--branch requires a branch name", shell_output("#{bin}/#{command} --branch 2>&1", 1)
    end
  end
end
