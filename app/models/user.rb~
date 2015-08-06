class User < ActiveRecord::Base
  #has_attached_file :document

  #validates_attachment :document,
   #                 :content_type => {:content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg','image/png', 'image/tif', 'image/gif'],
		#           				                      :message => "has to be in a proper format"}, 
    #                :styles => { :medium => "300x300>", :thumb => "100x100>", :large => "500x500>" },
     #               :storage => :dropbox,
      #              :dropbox_credentials => "#{Rails.root}/config/dropbox.yml",
       #             :dropbox_options => {
        #              :path => proc { |style| "#{style}/#{id}_#{avatar.original_filename}"}                               
         #           }


  has_attached_file :document,
                    :storage => :dropbox,
                    :dropbox_credentials => {app_key: '1p4j7bvuat2nk55',
                                           app_secret: 've3y6aqdx5hxn7d',
                                           access_token: current_user.token,
                                           access_secret: current_user.secret, 
                                           user_id: current_user.uid, 
                                           access_type: "app_folder"},
                    :styles => { :thumb => "100x100" },
                    :dropbox_options => {
                      :path => proc { |style| "#{style}/#{id}_#{document.original_filename}"}
                    }
  validates_presence_of :document
end
