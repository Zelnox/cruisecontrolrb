# Publish build status in a Campfire room.
# Requires the tinder gem: sudo gem install tinder.
#
# Based on Marc-André Cournoyer‘s campfire notifier
# http://code.macournoyer.com/svn/scout/trunk/extra/campfire_notifier.rb
#
# Adding the following lines to /path/to/builds/your_project/cruise_config.rb
#  <pre><code>
#    Project.configure do |project|
#      ...
#      project.campfire_notifier.account = 'mysubdomain'
#      project.campfire_notifier.username = 'bot@mydomain.com'
#      project.campfire_notifier.password = 'your_password'
#      project.campfire_notifier.room = 'Main room'
#      ...
#    end
#  </code></pre>
# Start the builder (./cruise build your_project)


require 'rubygems'
require 'tinder'

class CampfireNotifier
  attr_accessor :account, :username, :password, :room
  
  FIXED_MESSAGES = [
    "http://icanhascheezburger.files.wordpress.com/2008/02/funny-pictures-invisible-wii-tennis-cat.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/02/funny-pictures-boxing-cat-rocky.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/01/funny-pictures-finding-nemo-surfer-turtle.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/01/funny-pictures-evil-raccoon.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/01/1163354162444xy4lg2.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/01/funny-pictures-cat-axe.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/05/iloled-pam.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/06/yer-putter-iz-ready-now.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/01/1159587965947.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/11/raptorkitteni128389415799062500.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/11/funny-pictures-exclamation-cat.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/01/ceilingcat9xd.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/01/1160905871938.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/04/invisible_lawnmower.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/01/2001859367033693065_rs.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/06/lolpiggy.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/10/128340812179843750cansomeonehan.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/10/128341410720937500invisiblemowe.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/02/superkitty1.jpg",
    "http://icanhascheezburger.files.wordpress.com/2007/10/128347709988750000duntwurryill.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/06/funny-pictures-balogna-first-name-nom.jpg",
    "http://icanhascheezburger.files.wordpress.com/2008/06/funny-pictures-kitten-has-a-happy.jpg"
  ]
  
  BROKEN_MESSAGES = [
    "\nIM IN UR SERVR FIXIN TEH BUILD CUZ %s BROEK %s\n",
    "\nRLY RLY BUKKET... FAIL BUKKET! %s broke %s build\n",
    "\n%s.break!(%s.build)\n",
    "\nAh, ç‘a l‘air que %s va aller s‘asseoir au banc des punitions pour 5 mins pour avoir cassé la gueule à %s.\n",
    "\nNEVVVER GONNNNA GIIIIVE YOUUU UP, %s will turn around and make %s right\n",
    "\nWhy so serious? %s can fix %s.\n"
  ]
  
  def initialize(project = nil)
    @account = ''
    @username = ''
    @password = ''
    @room = ''
  end
  
  def build_broken(build, previous_build)
    send_message build, BROKEN_MESSAGES
  end

  def build_fixed(build, previous_build)
    send_message build, FIXED_MESSAGES
  end

  private
    # for git
    def get_build_info(build)
      revision = SourceControl::Git::LogParser.new.parse(build.changeset.split("\n"))
      [revision.first.author, build.project.name] if revision
    end
      
    def send_message(build, messages)
      campfire = Tinder::Campfire.new @account
      campfire.login @username, @password
      room = campfire.find_room_by_name @room
      
      message = messages[rand(messages.size)] % get_build_info(build)
      
      log = BuildLogParser.new(build.output)
      errors = log.failures_and_errors
      problem = build.output
      
      room.speak(message)
      room.speak(build.url)
      room.paste("errors.to_s")
      # room.paste(problem.to_s) if build.failed?
      [message, build.url, errors, problem]
    end
end

Project.plugin :campfire_notifier