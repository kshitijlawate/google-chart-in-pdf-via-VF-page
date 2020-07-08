public class GraphPageController
{
    public List<OppWrapper> wrList {get;set;}
    
    public String docId  {get; set;}

    public GraphPageController()
    {
        wrList = new List<OppWrapper>();
        //populating the list of wrapper 
        wrList = populateWrapper();
        
        docId = ApexPages.currentPage().getParameters().get('docId');
    }
    
    //querying on Opportunity to get Sum of Amount Grouped by Close Date
    public static List<AggregateResult> fetchOppDetails()
    {
        return [select CloseDate, SUM(Amount) amtSum 
                from Opportunity where Amount != null 
                group by CloseDate 
                order by CloseDate desc limit 10];
    }
    
    //Wrapper Class for displaying data on VF page
    public class OppWrapper
    {
        public String closeDate {get;set;}
        public Double amtSum {Get;set;}
        
        public OppWrapper()
        {
            amtSum = 0;
        }
    }
    
    //method that populates list of wrapper 
    public static List<OppWrapper> populateWrapper()
    {
        List<OppWrapper> owList = new List<OppWrapper>();
        for(aggregateResult aggr : fetchOppDetails())
        {
            OppWrapper ow = new OppWrapper();
            ow.closeDate = Date.valueOf(aggr.get('CloseDate')).format();
            ow.amtSum = Double.valueOf(aggr.get('amtSum'));
            owList.add(ow);
        }
        return owList;
    }
    
    //visualforce remoting method that is used to draw the chart
    @RemoteAction 
    public static List<OppWrapper> fetchOppData()
    {
        return populateWrapper();
    }
    
    //visualforce remoting method that inserts a document inside Salesforce
    @RemoteAction 
    public static String insertChartImage(String base64String)
    {
        String returnVal = 'ERROR';
        if(base64String != null)
        {
            //this line will remove "data:image/base64" string from the base64 String
            String imageString = base64String.substringAfter('base64,');            
            //converting the base64 string to Blob
            Blob docBody = EncodingUtil.base64Decode(imageString);
            //inserting a new document
            Document doc = new Document();
            doc.Name = 'MyImage_'+System.Now().format();
            doc.Body = docBody;
            doc.Type = 'png';
            //putting the document to Personal Folder for logged in User
            doc.FolderId = UserInfo.getUserId();
            insert doc;
            returnVal = doc.id;
        }
        return returnVal;
    }
}