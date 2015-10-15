import utilty.MySQLAccess;
import edu.uci.ics.crawler4j.crawler.CrawlConfig;
import edu.uci.ics.crawler4j.crawler.CrawlController;
import edu.uci.ics.crawler4j.fetcher.PageFetcher;
import edu.uci.ics.crawler4j.robotstxt.RobotstxtConfig;
import edu.uci.ics.crawler4j.robotstxt.RobotstxtServer;

public class Controller {
    public static void main(String[] args) throws Exception {
        String crawlStorageFolder = "D:\\SMNA\\Travelpod";
        int numberOfCrawlers = 1;

        CrawlConfig config = new CrawlConfig();
        config.setCrawlStorageFolder(crawlStorageFolder);
        config.setMaxDepthOfCrawling(2);
        /*
         * Instantiate the controller for this crawl.
         */
        PageFetcher pageFetcher = new PageFetcher(config);
        RobotstxtConfig robotstxtConfig = new RobotstxtConfig();
        RobotstxtServer robotstxtServer = new RobotstxtServer(robotstxtConfig, pageFetcher);
        CrawlController controller = new CrawlController(config, pageFetcher, robotstxtServer);
 
        /*
         * For each crawl, you need to add some seed urls. These are the first
         * URLs that are fetched and then the crawler starts following links
         * which are found in these pages
         */
        
        for(int i=0; i<= 33; i++){
        	//controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Singapore.html"); // Done
        	//controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Cambodia.html");	// Done
        	/*controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Thailand.html");	// Done
        	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Laos.html");		// Done
        	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Vietnam.html");	// Done
        	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Malaysia.html");	// Done
        	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Philippines.html");	// Done
        	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Indonesia.html");*/	// Done
        	//controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Myanmar.html"); // Done
       	}

        //controller.addSeed("http://www.travelpod.com/blogs/0/East+Timor.html"); // Done

        //for(int i=0; i<= 15; i++)
        //	controller.addSeed("http://www.travelpod.com/blogs/"+i+"/Brunei.html"); // Done
        
        
        /*
         * Start the crawl. This is a blocking operation, meaning that your code
         * will reach the line after this only when crawling is finished.
         */
        controller.start(MyCrawler.class, numberOfCrawlers);
        
        // Close DB connection
        MySQLAccess mySQL = MySQLAccess.getInstance();
        mySQL.close();
    }
}