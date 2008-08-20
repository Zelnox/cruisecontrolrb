require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../mocks/campfire')

class CampfireNotifierTest < Test::Unit::TestCase
  include FileSandbox
  
SIMPLE_LOG_ENTRY = <<EOF
commit e51d66aa4f708fff1c87eb9afc9c48eaa8d5ffce
tree 913027773a63829c82eeb8b626949436b216c857
parent bb52b2f82fea03b7531496c77db01f9348edbbdb
author Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600
committer Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600

    a comment
EOF

MANUAL_LOG_ENTRY = <<EOF
commit 7c65e
author Masked Poney <masked.poney@unprehensibletaskforce.com> 1213734958 +0500
    o hai, iz hax
EOF

FAILED_BUILD_LOG = <<EOF
/home/administrator/.cruise/projects/reception/work administrator$ ruby1.8 -e require 'rubygems' rescue nil; require 'rake'; load '/var/cruisecontrolrb/tasks/cc_build.rake'; ARGV << '--nosearch' << 'cc:build'; Rake.application.run; ARGV.clear
cd tmp/standoutjobs && git pull
(in /home/administrator/.cruise/projects/reception/work)
[CruiseControl] Invoking Rake task "cruise"
* refs/remotes/origin/master: fast forward to branch 'master' of git@github.com:standoutjobs/standoutjobs
  old..new: 8c059a5..c848ea8
Updating 8c059a5..c848ea8

Fast forward
 .../employers/candidacies_controller.rb            |   51 ++++-----
 app/models/candidacy.rb                            |   37 ++++++-
 app/views/employers/candidacies/index.html.erb     |    2 +-
 config/crontabs/app.conf.erb                       |    2 +-
 config/deploy.rb                                   |    7 +-
 doc/{README_FOR_APP => README.amazonaws}           |    0 
 README.rails21 => doc/README.rails21               |    0 
 doc/README.sphinx                                  |   40 +++++++
 doc/SPHINX                                         |   28 -----
 lib/tasks/cronjobs.rake                            |    3 +-
 test/fixtures/candidacies.yml                      |    7 +
 .../employers/candidacies_controller_test.rb       |  124 +++++++++++---------
 test/unit/candidacy_test.rb                        |   17 +++-
 13 files changed, 196 insertions(+), 122 deletions(-)
 rename doc/{README_FOR_APP => README.amazonaws} (100%)
 rename README.rails21 => doc/README.rails21 (100%)
 create mode 100644 doc/README.sphinx
 delete mode 100644 doc/SPHINX
rake aborted!
can't activate rubyforge (>= 1.0.0), already activated rubyforge-0.4.4]
             
(See full trace by running task with --trace)
uise/projects/reception/work/log/standoutjobs-test.log-l /home/administrator/.cr--More--(58%)
rake db:create db:schema:load db:fixtures:load RAILS_ENV=test
utjobs-test.pidome/administrator/.cruise/projects/reception/work/tmp/pids/stando--More--(64%)
on/work/tmp/pids/standoutjobs-test.pidome/administrator/.cruise/projects/recepti--More--(67%)
utjobs-test.pidome/administrator/.cruise/projects/reception/work/tmp/pids/stando--More--(71%)
on/work/tmp/pids/standoutjobs-test.pidome/administrator/.cruise/projects/recepti--More--(74%)
rake aborted!
execution expired
/home/administrator/.cruise/projects/reception/work/Rakefile:17
(See full trace by running task with --trace)
             
dir : /home/administrator/.cruise/projects/reception/work
on/build-07608/build.log 2>&1ar" >> /home/administrator/.cruise/projects/recepti--More--(98%)
exitstatus: 1
EOF

  def setup
    @mock_project = Object.new
    @mock_project.stubs(:name).returns("Test build")
    @mock_build = Object.new
    @mock_build.stubs(:project).returns(@mock_project)
    @notifier = CampfireNotifier.new
  end
  
  def test_build_name  
    assert_match /Test build/, @mock_build.project.name
  end
  
  def test_get_build_info
    @mock_build.stubs(:changeset).returns(SIMPLE_LOG_ENTRY)
    assert_equal ['Alexey Verkhovsky <alexey.verkhovsky@gmail.com>', "Test build"], 
                 @notifier.send(:get_build_info, @mock_build)
  end
  
  def test_get_build_info_manually_requested
    @mock_build.stubs(:changeset).returns(MANUAL_LOG_ENTRY)
    assert_equal ['Masked Poney <masked.poney@unprehensibletaskforce.com>', "Test build"], 
                 @notifier.send(:get_build_info, @mock_build)
  end
  
  def test_build_broken
    with_sandbox_project do |sandbox, project|
      sandbox.new :file => "build-2-failed.in9.235s/build.log", :with_content => FAILED_BUILD_LOG
      build = Build.new(project, 2)
      @mock_revision.stubs(:author).returns("Masked Poney")
      @mock_revision.stubs(:project).returns(@mock_project)
      @mock_build.stubs(:failed?).returns(true)
      @notifier.expects(:get_build_info).returns(['Masked Poney <masked.poney@unprehensibletaskforce.com>', "Test build"])
      build.stubs(:changeset).returns([@mock_revision])
      build.stubs(:url).returns("the build url")
      
      assert_equal '2', build.label
      assert_equal true, build.failed?
      assert_equal FAILED_BUILD_LOG, build.output
      
      results = @notifier.build_broken(build, @mock_previous_build)
      assert_match /(.)+/, results[0]
      assert_equal "the build url", results[1]
      assert_equal [], results[2]
      assert_equal FAILED_BUILD_LOG, results[3]
    end
  end
end