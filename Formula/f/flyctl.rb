class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.1.144",
      revision: "0f577818e24d165b7ddd07d905902c11e013631f"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "7b1724598f635d22d94b8b7949c1b4982b65b75e0bfe55a07bfe59c9922f649f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "7b1724598f635d22d94b8b7949c1b4982b65b75e0bfe55a07bfe59c9922f649f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "7b1724598f635d22d94b8b7949c1b4982b65b75e0bfe55a07bfe59c9922f649f"
    sha256 cellar: :any_skip_relocation, sonoma:         "af8472e11e2145ae9125bf0f632addab9851ed2d24da8c4ba4351ee4c11286a4"
    sha256 cellar: :any_skip_relocation, ventura:        "af8472e11e2145ae9125bf0f632addab9851ed2d24da8c4ba4351ee4c11286a4"
    sha256 cellar: :any_skip_relocation, monterey:       "af8472e11e2145ae9125bf0f632addab9851ed2d24da8c4ba4351ee4c11286a4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9a80b4feb7a0f4af6ba3e7ca178163d1f060548f803c99b430c9d1cc6f81b0c6"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.buildVersion=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "-tags", "production"

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
