const puppeteer = require("puppeteer");
const fs = require("fs");
const parse = require("csv-parse/lib/sync");

(async () => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  const csv_file = "data_urls.csv";
  const csv_data = fs.readFileSync(csv_file);
  const records = parse(csv_data, { columns: true });
  const data = {};
  for (let u = 0; u < records.length; u++) {
    const record = records[u];
    const id = record["id"];
    const url = record["url"];
    data[id] = {};

    if (url == "None") {
      continue;
    }

    await page.goto(url);
    const cereal_title = await page.$eval(
      "h1.prod-ProductTitle>div",
      e => e.innerHTML
    );
    data[id]["cereal_title"] = cereal_title;
    const cereal_about = await page.$eval(
      "div#product-about>div.about-desc",
      e => e.innerHTML
    );
    data[id]["cereal_about"] = cereal_about;
    const cereal_ingredients = await page.$eval(
      "p.Ingredients",
      e => e.innerHTML
    );
    data[id]["cereal_ingredients"] = cereal_ingredients;
    await page.click('li[data-automation-id="ProductPage-item-0"]');
    const cereal_specifications = await page.$eval(
      "div#specifications>table>tbody",
      e => e.innerHTML
    );
    data[id]["cereal_specifications"] = cereal_specifications;
    await page.click('li[data-automation-id="ProductPage-item-1"]');
    const cereal_nutrition = await page.$eval(
      "div#nutritionFacts>div.nutrition-facts",
      e => e.innerHTML
    );
    data[id]["cereal_nutrition"] = cereal_nutrition;
    const thumb_list = await page.$$(".prod-alt-image-wrapper .slider-slide");
    const image_dump = [];
    for (let i = 0; i < thumb_list.length; i++) {
      const thumb = thumb_list[i];
      await thumb.click();
      try {
        image_dump.push(
          await page.$eval(".hover-zoom-large-img", e => e.outerHTML)
        );
      } catch (error) {
        image_dump.push(
          await page.$eval(
            'img[data-tl-id="ProductPage-primary-image"]',
            e => e.outerHTML
          )
        );
      }
    }
    data[id]["cereal_images"] = image_dump;
  }

  const data_str = JSON.stringify(data, null, 2);
  fs.writeFileSync("data_dump.json", data_str);
  await page.close();
  await browser.close();
})();
