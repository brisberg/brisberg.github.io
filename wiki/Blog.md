# Blog Ideas

I would like to host a blog, but it would be nice to have a central place to manage the content on github and have it replicated to any hosting location I want. For example, it could publish to github-pages on the blog site as well as to Medium.com.

Medium has an OAuth2 API to allow publishing. I bet I can create some Github Actions pipelines to publish to multiple sources.

Also if possible I can make a separate Repo for my blog, and host it on a sub domain of my Domanin.

`blog.brisberg.dev`

I can leave this main repo as a main information and forarding point for any other project I have hosted on github pages.

https://stackoverflow.com/questions/46455900/subdomain-of-website-for-github-pages-project
https://christopherkade.com/posts/subdomain-githubpages

Actually got it to work by pointing the DNS CNAME rules to `brisberg.github.io`. Need to make a blog post about this.
