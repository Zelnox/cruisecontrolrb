require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CampfireNotifierTest < Test::Unit::TestCase
  
SIMPLE_LOG_ENTRY = <<EOF
commit e51d66aa4f708fff1c87eb9afc9c48eaa8d5ffce
tree 913027773a63829c82eeb8b626949436b216c857
parent bb52b2f82fea03b7531496c77db01f9348edbbdb
author Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600
committer Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600

    a comment
EOF

  def setup
    @mock_project = Object.new
    @mock_project.stubs(:name).returns("Test build")
    @mock_build = Object.new
    @mock_build.stubs(:project).returns(@mock_project)
    @mock_build.stubs(:changeset).returns(SIMPLE_LOG_ENTRY)
  end
  
  def test_build_name  
    assert_match /Test build/, @mock_build.project.name
  end
  
  def test_get_build_info
    notifier = CampfireNotifier.new
    assert_equal ['Alexey Verkhovsky <alexey.verkhovsky@gmail.com>', "Test build"], 
                 notifier.send(:get_build_info, @mock_build)
  end
end