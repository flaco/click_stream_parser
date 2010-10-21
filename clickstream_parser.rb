require 'yaml'
servers = ["app1", "app2","app3","app4","app5","app6"]
for server in servers
  File.open("production.log").each do |out|
    next unless out.index("audit")
    next unless out.index("user_id")
    pre_yaml = out.split('[production:audit]:')[1].gsub(/\n/, '')
    post_yaml = YAML::parse(pre_yaml) rescue next
    current_user = post_yaml['user_id'].value  
    unless users.index(current_user.to_i).nil?
      user = post_yaml['user_id'].value rescue ''
      when_stamp = post_yaml['when'].value.downcase.gsub(/[a-z]/, '').gsub(/-|:/, '') rescue ''
      controller =  post_yaml['params']['controller'].value rescue ''
      action = post_yaml['params']['action'].value rescue ''
      ActiveRecord::Base.connection.execute(["
      insert into clickstream values('', '?', '?','?', '?', now(),'' ) 
      ;",user, when_stamp, controller, action])
    else
      puts "skipping user_id: " + current_user.to_s  
    end
  end
end