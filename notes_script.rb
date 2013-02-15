require 'rubygems'
require 'prawn'
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

result = {}
# result["notes_json_result"] = file_insert({'title'=>"Notes JSON", "desctiption"=>"Json of kindle notes", "mimeType"=>"application/json"}, 'notes.json', 'application/json')

File.open("results.yml", 'w+') { |f| f.write(result.to_yaml) }

pdf = Prawn::Document.new

pdf.text "Notes and highlights from Books", align: :center, size: 16
books_array.each do |book|
	# notes_result_file.write(books)
	pdf.text book["name"], align: :center, size: 14
	pdf.text book["author"], align: :center, styles: :italic
	book_notes = book["notes"].map { |n| n["text"] }
	pdf.text book_notes.join("\n\n")
	pdf.start_new_page
end

pdf.render_file("notes.pdf")

result["notes_pdf_result"] = file_insert({'title'=>"Kindle Notes", "desctiption"=>"kindle notes", "mimeType"=>"application/pdf"}, 'notes.pdf', 'application/pdf')

File.open("results.yml", 'w+') { |f| f.write(result.to_yaml) }


notes_file.close

