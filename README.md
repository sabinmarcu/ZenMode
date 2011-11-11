# ZenMode

This nifty little bash script edits the `hosts` file so that you cannot access these websites : 

- [9GAG](http://9gag.com/)
- [Facebook](http://facebook.com/)
- [Smartphowned](http://smartphowned.com/)
- [Unfriendable](http://unfriendable.com/)
- [Google+](http://plus.google.com/)
- [Twitter](http://twitter.com/)
- [Klout](http://klout.com/)
- [Demotivare](http://demotivare.com/)
- [PopCult](http://popcult.ro/)

1) To add a new website to the denial list, just `add a new file` named after the `domain of the website` to the `denials` folder.

On a Unix environment a simple :
	
	touch website.com
	
While in the `denials` dir should be enough. Remember to restart zen mode if you make any changes to the denials list ^^

Or you can just run this, which also restarts zen mode automatically:

	zenmode deny website.com

## For any other help, please just run the app with no params whatsoever :)

