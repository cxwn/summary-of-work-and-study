```cmd
c:\Users\v-ruidu\Documents\GitHub\Crawler_meneame.net>scrapy startproject CrawlerMeneame
New Scrapy project 'CrawlerMeneame', using template directory 'c:\\users\\v-ruidu\\appdata\\local\\programs\\python\\python36\\lib\\site-packages\\scrapy\\templates\\project', created in:
    c:\Users\v-ruidu\Documents\GitHub\Crawler_meneame.net\CrawlerMeneame

You can start your first spider with:
    cd CrawlerMeneame
    scrapy genspider example example.com
```
创建一个spider，爬虫名称+域名
```cmd
c:\Users\v-ruidu\Documents\GitHub\Crawler_meneame.net\CrawlerMeneame>scrapy genspider Meneame meneame.net
Created spider 'Meneame' using template 'basic' in module:
  CrawlerMeneame.spiders.Meneame
```
修改settings的以下内容：
```
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36'
```
```cmd
scrapy shell -s USER_AGENT="Mozilla/5.0" https://www.meneame.net/
```