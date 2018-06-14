class VisitorsController < ApplicationController
  before_action :check_collection

 def add
   #Test if collection exists
   client = Aws::Rekognition::Client.new()
   image=params[:img]
   s3 = Aws::S3::Resource.new(region: 'eu-west-1')
   obj = s3.bucket('jcristanreko01').object('javier4.jpg')
   decoded_image =Base64.decode64(image)
   print "antes de upload_file"
   obj.upload_file(decoded_image)
   print "pase de upload_file"

   image=image.gsub("data:image/jpeg;base64,", "")
   name = params[:name]
   name = name.gsub(" ","_")
   response = client.index_faces({
       collection_id: "faceapp_test",
       external_image_id: name,
       image: {
         bytes: Base64.decode64(image)
       },
        detection_attributes: ["ALL"]
     })
  
   puts response
   render :json => response.face_records.to_json
  end

 def add_image_s3
   #Test if collection exists
   service = AWS::S3.new(region: 'eu-west-1')

   obj = s3.bucket('jcristanreko01').object('javier.jpg')
   image=params[:img]
   obj.upload_file(image)
   
  end
    #code


  def reset
    client = Aws::Rekognition::Client.new()
    resp = client.delete_collection({
      collection_id: "faceapp_test"
    })
    flash[:notice] = 'Successfully checked in'
    redirect_to({ action: 'audit' }, alert: "Collection was recreated")
  end


def audit
  client = Aws::Rekognition::Client.new()
  @faces = client.list_faces({ collection_id: "faceapp_test" }).faces
end

 def find
   client = Aws::Rekognition::Client.new()
   image=params[:img]
   image=image.gsub("data:image/jpeg;base64,", "")
   begin
   response = client.search_faces_by_image({
     collection_id: "faceapp_test",
     max_faces: 1,
     face_match_threshold: 95,
     image: {
       bytes: Base64.decode64(image)
     }
   })
 rescue
    render json: {:message => "No face detected!"}.to_json
    return
  end
   if response.face_matches.count > 1
    render json: {:message => "Too many faces found"}.to_json
   elsif response.face_matches.count == 0
   render json: {:message => "Person not detected in collection!"}.to_json
   else
     # "Comparison finished - detected #{ response.face_matches[0].face.external_image_id } with #{ response.face_matches[0].face.confidence } accuracy."
   render json:   {:id => response.face_matches[0].face.external_image_id, :confidence => response.face_matches[0].face.confidence, :message => "Face found!"}.to_json
   end
 end

 private

 def check_collection
   client = Aws::Rekognition::Client.new()
   collections = client.list_collections({}).collection_ids
   client.create_collection({ collection_id: "faceapp_test" }) if !(collections.include? "faceapp_test")
 end

end
