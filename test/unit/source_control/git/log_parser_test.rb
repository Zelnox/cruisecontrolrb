require File.dirname(__FILE__) + '/../../../test_helper'

module SourceControl
  class Git::LogParserTest < Test::Unit::TestCase

SIMPLE_LOG_ENTRY = <<EOF
commit e51d66aa4f708fff1c87eb9afc9c48eaa8d5ffce
tree 913027773a63829c82eeb8b626949436b216c857
parent bb52b2f82fea03b7531496c77db01f9348edbbdb
author Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600
committer Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600

    a comment
EOF

COMPLICATED_LOG_ENTRY = <<EOF
commit 5d5e4638354f09b9694848a2f6479da494540fa6
tree 03556209c6df6d0253ea95e62348a55bc683435a
parent 7835c341686c6818178ef1fbb25e31a737127ff5
author Thanh Vinh Tang <zelnox@gmail.com> 1213919568 -0400
committer Thanh Vinh Tang <zelnox@gmail.com> 1213919568 -0400

    Should resolve bug #7376. A cookie named referer is created the first time, usually on a job on a subdomain. Applying for it will redirect to main site, where another cookie of the same name overwrites the first one. Forcing all ref

commit 7835c341686c6818178ef1fbb25e31a737127ff5
tree b56180b80b112d136aa1ed6a625e0ad5807bce9d
parent 9d99e46ec174ebfb261cbccdf4240d2fabcf28a4
parent 59eab4c3eec82682ec970e0eaa5d9caef1f2e802
author Fred Ngo <fredngo@gmail.com> 1213895831 -0400
committer Fred Ngo <fredngo@gmail.com> 1213895831 -0400

    Merge branch 'master' of git@github.com:standoutjobs/standoutjobs

commit 9d99e46ec174ebfb261cbccdf4240d2fabcf28a4
tree a7e5165ffaa0f5fe5b8e44d140bb2298de8bb115
parent b827f6450efe6762941481d2b20d172db3bc97b3
author Fred Ngo <fredngo@gmail.com> 1213895812 -0400
committer Fred Ngo <fredngo@gmail.com> 1213895812 -0400

    Migrating to Capistrano 2.4.0
EOF

    def test_parse_should_work
      expected_revision = Git::Revision.new(
                              'e51d6',
                              'Alexey Verkhovsky <alexey.verkhovsky@gmail.com>',
                              Time.at(1209921867))
      revisions = Git::LogParser.new.parse(SIMPLE_LOG_ENTRY.split("\n"))
      assert_equal [expected_revision], revisions

      assert_equal expected_revision.number, revisions.first.number
      assert_equal expected_revision.author, revisions.first.author
      assert_equal expected_revision.time, revisions.first.time
    end

    def test_parse_line_should_recognize_commit_id_and_truncate_it_to_first_five_characters
      parser = Git::LogParser.new
      parser.send(:parse_line, "commit e51d66aa4f708fff1c87eb9afc9c48eaa8d5ffce")
      assert_equal 'e51d6', parser.instance_variable_get(:@id)
    end

    def test_parse_line_should_recognize_author
      parser = Git::LogParser.new
      parser.send(:parse_line, "author Alexey Verkhovsky <alexey.verkhovsky@gmail.com> 1209921867 -0600")
      assert_equal 'Alexey Verkhovsky <alexey.verkhovsky@gmail.com>', parser.instance_variable_get(:@author)
      assert_equal Time.at(1209921867), parser.instance_variable_get(:@time)
    end

    def test_commit_message_should_recognize_lines_that_start_with_four_spaces_as_commit_lines
      parser = Git::LogParser.new
      assert_false parser.send(:commit_message?, "parent bb52b2f82fea03b7531496c77db01f9348edbbdb")
      assert parser.send(:commit_message?, "    a comment")
    end
    
    def test_parse_big_changeset
      parser = Git::LogParser.new
      changeset = parser.parse(COMPLICATED_LOG_ENTRY)
      assert_equal 3, changeset.length
      # puts changeset.inspect
    end

  end
end
