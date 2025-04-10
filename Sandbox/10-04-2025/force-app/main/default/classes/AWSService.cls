public class AWSService {

    public string bucketName {get;set;}
    public string methodName {get;set;}
    public string hostName {get;set;}

    public AWSService(string bucket, string method, string host)
    {
        bucketName=bucket;
        methodName=method;
        hostName=host;
    }

    public string ContentType(string fileType)
    {
        switch on fileType?.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';

            }
            when 'pdf'
            {
                return 'application/pdf';

            }
            when else {
                return 'image/jpeg';
            }
        }
    }

    public void UploadDocuments(string recordId, List<ContentVersion> versions)
    {
        if(string.isBlank(this.bucketName) || string.isBlank(this.hostName))
        {
            throw new BaseException('Set AWS credential');
        }
        List<DragDropToCloud__Cloud_Documents__c> cloudDocuments = new List<DragDropToCloud__Cloud_Documents__c>();
        String folderName = recordId.substring(0,3)+'-'+((Id)recordId).getSobjectType().getDescribe().getName().toLowerCase()+'/'+recordId+'/';
        List<ContentVersion> versionsToUpdate = new List<ContentVersion>();
        for(ContentVersion attach : versions) {
            try
            {
                //File Content
                String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');

                String filename = attach.Title;
                string contentType=ContentType(attach?.FileExtension);
                String s3FileName = String.join(filename.toLowerCase().split(' '), '_')+ '.'+attach?.FileExtension?.toLowerCase();

                String extension = folderName + s3FileName;
                HttpRequest req = new HttpRequest();
                req.setMethod(this.methodName);
                req.setEndpoint('callout:AWS_S3/' + extension);
                req.setHeader('Host', this.bucketName + '.' + this.hostName);
                req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
                req.setHeader('Content-Encoding', 'UTF-8');
                req.setHeader('Content-type', contentType);
                req.setHeader('Connection', 'keep-alive');
                req.setHeader('Date', formattedDateString);
                req.setHeader('ACL', 'public-read');
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
                req.setBodyAsBlob(pdfBlob);

                Http http = new Http();
                HTTPResponse res = http.send(req);
                if (res.getStatusCode() == 200 || res.getStatusCode()==201)
                {
                    //Store Information in Object
                    //Will be used for retrieving files
                    DragDropToCloud__Cloud_Documents__c cloudDocument =new DragDropToCloud__Cloud_Documents__c();
                    cloudDocument.DragDropToCloud__Access_Level__c = 'public-read';
                    cloudDocument.Name = s3FileName;
                    cloudDocument.DragDropToCloud__Actual_File_Name__c = s3FileName;
                    cloudDocument.DragDropToCloud__Bucket_Name__c = this.bucketName;
                    cloudDocument.DragDropToCloud__Hidden_File_Version_No__c = 1;
                    cloudDocument.DragDropToCloud__File_Size_Numeric__c = attach.ContentSize;
                    cloudDocument.DragDropToCloud__Folder_Id__c = extension;
                    if (((Id)recordId).getSobjectType() == Room__c.SObjectType) {
                        cloudDocument.RoomRef__c = recordId;
                    } else if (((Id)recordId).getSobjectType() == Apartment__c.SObjectType){
                        cloudDocument.ApartmentRef__c = recordId;
                    } else if (((Id)recordId).getSobjectType() == Property__c.SObjectType){
                        cloudDocument.PropertyRef__c = recordId;
                    }
                    cloudDocuments.add(cloudDocument);
                    attach.IsMigrateToS3__c = true;
                    versionsToUpdate.add(new ContentVersion(Id = attach.Id, IsMigrateToS3__c = true));

                }
            }
            catch(Exception ex)
            {
                System.debug(ex.getMessage());
            }
        }
        insert cloudDocuments;
        update versionsToUpdate;
    }

}