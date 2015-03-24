package org.velobg.JoinSofiaAgkImage;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import javax.imageio.ImageIO;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

public class JoinSofiaOupImage {

	File outputFolder = new File(".");
	
	int gTierCount;

	int gImageWidth;
	int gImageHeight;
	int gTileSize;
	
	int gTierTileCount[];
	int gTileCountWidth[];
	int gTileCountHeight[];
	int gTierWidth[];
	int gTierHeight[];
		
	URL baseUrl;
	
	URL getImageUrl(int tier, int x, int y) throws MalformedURLException {
		int theOffset = (y * gTileCountWidth[tier]) + x;
		int theTier = 0;
		while (theTier < tier) {
			theOffset = theOffset + gTierTileCount[theTier];
			theTier++;
		}
		int theCurrentOffsetChunk = theOffset / 256;
		return new URL(baseUrl, "TileGroup" + theCurrentOffsetChunk + "/" + tier + "-" + x + "-" + y + ".jpg");
	}
	
	public void log(String str) {
		System.out.println(str);
	}
	
	public void finishedDownloadingImage(int image, int numImages) {
	}
	
	void downloadAll(String urlStr) throws Exception {
		urlStr = urlStr.trim();
		String separator = "/displayImage.php?folder=";
		if (!urlStr.contains(separator)) {
			log("URL should contain '" + separator + "'");
			return;
		}
		outputFolder.mkdirs();
		baseUrl = new URL(urlStr.replace(separator, "/"));
		URL xmlUrl = new URL(baseUrl, "ImageProperties.xml");
		
		InputStream is = xmlUrl.openStream();
		SAXBuilder builder = new SAXBuilder(false);
		Document doc = builder.build(is);
		is.close();
		Element xmlRoot = doc.getRootElement();
		
		gImageWidth = Integer.parseInt(xmlRoot.getAttributeValue("WIDTH"));
		gImageHeight = Integer.parseInt(xmlRoot.getAttributeValue("HEIGHT"));
		gTileSize = Integer.parseInt(xmlRoot.getAttributeValue("TILESIZE"));

		int tempWidth = gImageWidth;
		int tempHeight = gImageHeight;

		// the algorythm in buildPyramid
		gTierCount = 1;
		while ((tempWidth > gTileSize) || (tempHeight > gTileSize)) {
			// if (pyramidType == "Div2") {
			tempWidth = tempWidth / 2;
			tempHeight = tempHeight / 2;
			gTierCount++;
		}
		
		gTierTileCount = new int[gTierCount];
		gTileCountWidth = new int[gTierCount];
		gTileCountHeight = new int[gTierCount];
		gTierWidth = new int[gTierCount];
		gTierHeight = new int[gTierCount];

		tempWidth = gImageWidth;
		tempHeight = gImageHeight;

		int j = gTierCount - 1;
		while (j >= 0) {
			gTileCountWidth[j] = (int) Math.ceil((double) tempWidth / gTileSize);
			gTileCountHeight[j] = (int) Math.ceil((double) tempHeight / gTileSize);
			gTierTileCount[j] = gTileCountWidth[j] * gTileCountHeight[j];
			gTierWidth[j] = tempWidth;
			gTierHeight[j] = tempHeight;
			// if (pyramidType == "Div2") {
			tempWidth = tempWidth / 2;
			tempHeight = tempHeight / 2;
			j--;
		}
		
		int numImages = 0;
		for (int i : gTierTileCount) {
			numImages += i;
		}
		
		int image = 0;
		for (int tier = 0; tier < gTierCount; tier++) {
			BufferedImage img = new BufferedImage(gTierWidth[tier], gTierHeight[tier], BufferedImage.TYPE_BYTE_INDEXED);
			Graphics g = img.getGraphics();
			g.setColor(Color.white);
			g.fillRect(0, 0, gTierWidth[tier], gTierHeight[tier]);
			for (int x = 0; x < gTileCountWidth[tier]; x++) {
				for (int y = 0; y < gTileCountHeight[tier]; y++) {
					URL url = getImageUrl(tier, x, y);
					try {
						BufferedImage bi = ImageIO.read(url);
						g.drawImage(bi, x * gTileSize, y * gTileSize, null);
						finishedDownloadingImage(++image, numImages);
					} catch (Exception e) {
						log("Error reading image " + url + ". Image skipped");
					}
				}
			}
			File fou = new File(outputFolder, "zoomLevel-" + tier + ".jpg");
			ImageIO.write(img, "jpg", fou);
			log("Written image " + fou.getAbsolutePath());
		}
	}

	public static void main(String[] args) throws Exception {
		String testUrl = "http://sofia-agk.com/esoft/planove/displayImage.php?folder=OUP_GOTOV_10000_2010-01-26/";
		new JoinSofiaOupImage().downloadAll(testUrl);
	}
}
