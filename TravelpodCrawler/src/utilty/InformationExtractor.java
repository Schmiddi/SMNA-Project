package utilty;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Set;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import edu.uci.ics.crawler4j.crawler.Page;
import edu.uci.ics.crawler4j.parser.HtmlParseData;
import edu.uci.ics.crawler4j.url.WebURL;
import model.BlogEntry;

public class InformationExtractor {

	final static String beginningOfBlogUrl = "http://www.travelpod.com/travel-blog-entries/";
	final static String endAfterBlogID = "/[0-9]*/tpod.html";
	final static String endAfterAuthorName = "/[^/]+/[0-9]*/tpod.html";

	public static BlogEntry analyseBlogEntry(Page page) {
		BlogEntry entry = null;

		String url = page.getWebURL().getURL();

		if (page.getParseData() instanceof HtmlParseData) {
			HtmlParseData htmlParseData = (HtmlParseData) page.getParseData();
			String html = htmlParseData.getHtml();

			Document doc = Jsoup.parse(html);

			Element post = doc.getElementById("post");
			Element sidebar = doc.getElementById("sidebar");
			
			entry = new BlogEntry();

			entry.setAuthorName(InformationExtractor.getAuthorName(url));
			entry.setAuthorCountry(InformationExtractor.getAuthorCountry(sidebar));
			entry.setBlogID(InformationExtractor.getBlogID(url));
			entry.setBlogEntryID(InformationExtractor.getBlogEntryID(url));
			InformationExtractor.getSetLocation(post, entry);
			entry.setDate(InformationExtractor.getDate(post));
			entry.setContent(post.ownText());
		}

		return entry;

	}

	public static String getAuthorCountry(Element sidebar){
		// Home country title, inclusive author name and "is from"
		String home = sidebar.select("a[rel=\"author\"] + img").attr("title");
		
		// Removing of the author name and "is from", only the city and country will remain
		home = home.substring(home.lastIndexOf("is from") + "is from".length()).trim();
		
		// If there is a city, remove the city - we only keep the country
		if(home.lastIndexOf(",") >= 0)
			home = home.substring(home.lastIndexOf(",") + 1).trim();
		
		return home;
	}
	public static String getBlogID(String url) {

		url = url.replaceFirst(beginningOfBlogUrl, "");
		url = url.replaceFirst(endAfterBlogID, "");

		return url;
	}

	public static String getAuthorName(String url) {

		url = url.replaceFirst(beginningOfBlogUrl, "");
		url = url.replaceFirst(endAfterAuthorName, "");

		return url;
	}

	public static String getBlogEntryID(String url) {
		url = url.replaceFirst(beginningOfBlogUrl, "");
		url = url.replaceFirst("/tpod.html", "");

		return url;
	}

	public static Date getDate(Element post) {
		String date = post.getElementsByClass("date").first().text();

		DateFormat format = new SimpleDateFormat("E, MMMM d, yyyy", Locale.ENGLISH);
		Date myDate = null
				;
		try {
			myDate = format.parse(date);
		} catch (ParseException e) {
			e.printStackTrace();
		}

		return myDate;
	}

	public static void getSetLocation(Element post, BlogEntry entry) {
		Elements locations = post.select("a[rel$=tag]");
		
		entry.setCity(locations.get(0).text());
		if (locations.size() == 3) {
			entry.setState(locations.get(1).text());
			entry.setCountry(locations.get(2).text());
		}
		if (locations.size() == 2) {
			entry.setCountry(locations.get(1).text());
		}
	}
}
