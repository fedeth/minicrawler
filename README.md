# MiniCrawler
This script explores recursively all internal links of a given domain and retrives useful info (assets' url, inbound/outbound links between pages, etc...) for each of them.


## IDEA
![logic](https://i.ibb.co/0QWN3bC/Untitled-document-3.jpg)
Script logic


![Graph](https://i.ibb.co/BtXKPnX/Untitled-document-1.jpg)
A picture that I drew to visualize the problem before I started to code.

## Usage

```bash
$ iex -S mix
iex(1)> MiniCrawler.start
```
## Tested cases
- https://elixir-lang.org - depth: 6
- https://sedna.com - depth 4
- http://sinatrarb.com - depth 5 (best example)
- https://www.emojicode.org 
