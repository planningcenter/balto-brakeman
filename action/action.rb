# frozen_string_literal: true

require "json"
require "ostruct"

require_relative "./install_gems"
require_relative "./git_utils"
require_relative "./check_run"

if ENV["BALTO_LOCAL_TEST"]
  require_relative "./fake_check_run"
end

CHECK_NAME = "brakeman"

event = JSON.parse(
  File.read(ENV["GITHUB_EVENT_PATH"]),
  object_class: OpenStruct
)

check_run_class = ENV["BALTO_LOCAL_TEST"] ? FakeCheckRun : CheckRun

check_run = check_run_class.new(
  name: CHECK_NAME,
  owner: event.repository.owner.login,
  repo: event.repository.name,
  token: ENV["GITHUB_TOKEN"],
)

check_run_create = check_run.create(event: event)

if !check_run_create.ok?
  raise "Couldn't create check run #{check_run_create.inspect}"
end

BRAKEMAN_TO_GITHUB_SEVERITY = {
  "High" => "failure",
  "Medium" => "failure",
  "Weak" => "warning",
}.freeze

def git_root
  @git_root ||= Pathname.new(GitUtils.root)
end

def working_dir
  @working_dir ||= Pathname.new(Dir.getwd)
end

def repo_path
  @repo_path ||= ENV["BALTO_LOCAL_TEST"] || ENV["GITHUB_TEST"] ? "test/app" : git_root
end

def file_fullpath(relative_path)
  if git_root != working_dir
    File.join(working_dir.relative_path_from(git_root), relative_path)
  else
    relative_path
  end
end

def generate_annotations(compare_sha:)
  annotations = []

  brakeman_json = Bundler.with_original_env do
    `brakeman --path "#{repo_path}" --quiet --format json`
  end

  brakeman_output = JSON.parse(brakeman_json, object_class: OpenStruct)

  brakeman_output.warnings.each do |warning|
    path = file_fullpath(warning.file)

    # change_ranges = GitUtils.generate_change_ranges(path, compare_sha: compare_sha)

    # return unless change_ranges.any? { |range| range.include?(warning.line) }

    annotations.push(
      path: path,
      start_line: warning.line,
      end_line: warning.line,
      annotation_level: BRAKEMAN_TO_GITHUB_SEVERITY[warning.confidence],
      message: warning.message
    )
  end

  annotations
end

begin
  previous_sha = if event.pull_request.nil?
                   event.before
                 else
                   event.pull_request.base.sha
                 end

  annotations = generate_annotations(compare_sha: previous_sha)
rescue Exception => e
  puts e.message
  puts e.backtrace.inspect
  resp = check_run.error(message: e.message)
  p resp
  p resp.json
else
  check_run.update(annotations: annotations)
end
