import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

import utilty.InformationExtractor;
import utilty.MySQLAccess;
import model.BlogEntry;
import edu.uci.ics.crawler4j.crawler.Page;
import edu.uci.ics.crawler4j.crawler.WebCrawler;
import edu.uci.ics.crawler4j.parser.HtmlParseData;
import edu.uci.ics.crawler4j.url.WebURL;

public class MyCrawler extends WebCrawler {

	private final static Pattern FILTERS = Pattern.compile(".*(\\.(css|js|gif|jpg" + "|png|mp3|mp3|zip|gz))$");

	/**
	 * This method receives two parameters. The first parameter is the page in which we have discovered this new url and
	 * the second parameter is the new url. You should implement this function to specify whether the given url should
	 * be crawled or not (based on your crawling logic). In this example, we are instructing the crawler to ignore urls
	 * that have css, js, git, ... extensions and to only accept urls that start with "http://www.ics.uci.edu/". In this
	 * case, we didn't need the referringPage parameter to make the decision.
	 */
	public boolean shouldVisit(Page referringPage, WebURL url) {
		String href = url.getURL().toLowerCase();
		return !FILTERS.matcher(href).matches() && href.startsWith("http://www.travelpod.com/travel-blog-entries");
	}

	/**
	 * This function is called when a page is fetched and ready to be processed by your program.
	 */
	public void visit(Page page) {
		BlogEntry entry = InformationExtractor.analyseBlogEntry(page);

		MySQLAccess mySQL = MySQLAccess.getInstance();
		try {
			mySQL.writeBlogEntry(entry);
		} catch (SQLIntegrityConstraintViolationException e) {
			System.out.println("Doublicate - ignored");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
