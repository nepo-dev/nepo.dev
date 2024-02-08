Hey, somehow you've reached the repo for my personal blog. Hi!

If you're looking for the deployed site it's in https://blog.jnepo.dev/

## Usage

- `make` or `make build`: generate site.
You just need to commit and push it for it to be deployed.
- `make debug`: generate site for local debugging.
The main url is replaced with the local project's path in the file system.

## Why not use an existing static site generator?

Because:

- They usually have too many things. It's hard to learn them
and at any time they might be updated and something will break.
Also Jekyll forces you to use node and Ruby and lots of dependencies
and I can't deal with that many things for just a blog.
- I was bored and I thought a bash-only site generator
would be fun to make.
- I wanted to learn more about bash and GNU/Linux programs.

