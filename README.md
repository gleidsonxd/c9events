# Cloud 9 - Sinatra

## Setting Up Cloud9
- Go to `c9.io` and log in
- Create a new workspace
  - `Workspace name` = `hello-world`
  - `Clone from Git or Mercurial URL` = `https://gist.github.com/2f5f8bd2fdf583dc757a.git`
  - (everything else at defaults)


## In Cloud9
Check out the files you have in this folder, see what they have.

In the terminal (at the bottom) type:
- `bundle install`
  - this will install the ruby `gem`s you need to have sinatra run
- `ruby hello_world.rb -o $IP -p $PORT`
  - this will run the file hello_world.rb, and tell it to make the site available online at a location.
  - Cloud 9 has wired things up so `$IP` and `$PORT` contains what it should on their server.
- In the menu bar, click `Preview` => `Preview Running Application` and a browser pane will appear.
- After each change you make to our files:
  - save the file(s)
  - refresh the browser pane

## Templates
- Make a folder `views`
- Add the file `views/index.erb` with the content
```
<h1>This is my index.erb file contents oh my.</h1>
```
- modify `hello_world.rb` to use `index.erb` instead of returning a string.
  - Within the `get '/' do`: change `"Hello World! Welcome to Ruby!"` to `erb :index`.