require 'rubygems'
require_relative "google_file_upload"
include GoogleFileUpload
notes_file = File.open("clippings.txt")
begin
  line_fl = File.open("line_file")
  line_no = line_fl.readline.to_i
rescue
  line_no = 0
end

books_array = Array.new
notes_text = notes_file.read
notes_array = notes_text.split(/==========/)
notes_array.each do |note|
	book = Hash.new
	note_array = note.split(/\r\n/)
	break if note_array.empty?
	pos = 0
	while note_array[pos] == ""
		pos = pos + 1
	end
	book["name"] = note_array[pos][/[^\(]+/].rstrip
	book["author"] = note_array[pos][/(\(.*\))/].gsub(/[()]/, "")
	book["notes"] = []
	note_hash = {"meta"=>note_array[pos + 1], "text"=>note_array[pos + 3]}
	book["notes"] << note_hash
	position = books_array.index { |b| b["name"] == book["name"]}
	if position.nil?
		books_array << book
	else
		books_array[position]["notes"] << note_hash
	end
end

File.open("notes.json", "w") { |f| f.write(books_array) }

file_insert({'title'=>"Notes JSON", "desctiption"=>"Json of kindle notes", "mimeType"=>"application/json"}, 'notes.json', 'application/json')
notes_file.close

