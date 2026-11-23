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
      url "https://github.com/kitten/git-porter/releases/download/v0.1.1/git-porter-0.1.1-macos-arm64.tar.gz"
      sha256 "a2d1c95754a01c8bd6020199562fe4b0e5a571e07d11caaf89cf6f599b611cc2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.1/git-porter-0.1.1-linux-arm64.tar.gz"
      sha256 "b0cb5c5cc12c4f796a4b224515912c57915eb4da1ab43e5250af541fd1a49f30"
    end
    on_intel do
      url "https://github.com/kitten/git-porter/releases/download/v0.1.1/git-porter-0.1.1-linux-x86_64.tar.gz"
      sha256 "c6bb73b1e05166f59f9a8552dcae826f3e5b1165a7291e00a6d28529cccce0a9"
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
