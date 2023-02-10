all: remove-all-xcodeproj generate-all-xcodeproj
genOpen: all xopen

remove-all-xcodeproj:
	./Scripts/remove-all-xcodeproj.sh

generate-all-xcodeproj:
	echo "---Gerando Projeto---"
	xcodegen
	echo "---Projeto Gerado---"

xopen:
	xopen
