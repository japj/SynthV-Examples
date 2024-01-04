// paste Dorico lyrics
// based in Claire'e Paste Lyrics script at https://github.com/claire-west/svstudio-scripts

// pastes the clipboard content to the selected notes as lyrics
var SCRIPT_TITLE = "Paste Dorico Lyrics";

// the separator to use between each lyric when pasting to multiple notes
var DELIMITER = ' ';

function getClientInfo() {
  return {
    "name": SV.T(SCRIPT_TITLE),
    "author": "Jeroen Janssen",
    "versionNumber": 1,
    "minEditorVersion": 65537
  }
}

function pasteLyricsToSelection() {
  var editorView = SV.getMainEditor();
  var selection = editorView.getSelection();
  var selectedNotes = selection.getSelectedNotes();
  if (selectedNotes.length == 0) {
    return;
  }

  var clipboardText = SV.getHostClipboard();
  clipboardText = clipboardText.replace(/  /g," ");
  clipboardText = clipboardText.replace(/~/g, "-");
  clipboardText = clipboardText.replace(/_/g,"");
  var lyrics = clipboardText.split(DELIMITER);
  for (var i = 0; i < selectedNotes.length && i < lyrics.length; i++) {
    selectedNotes[i].setLyrics(lyrics[i]);
  }
}

function main() {
  pasteLyricsToSelection();
  SV.finish();
}
