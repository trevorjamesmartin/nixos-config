package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func api() {

	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(hyperText()))
	})

	handleConfig := func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(configText()))
	}

	handleJSON := func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Content-Type", "application/json")
		w.Write([]byte(jsonText()))
	}

	uploadFile := func(w http.ResponseWriter, r *http.Request) {
		r.ParseMultipartForm(10 << 20)
		file, handler, err := r.FormFile("imageFile")

		if err != nil {
			fmt.Println("ERROR getting file")
			fmt.Println(err)
			return
		}
		defer file.Close()

		fmt.Printf("Uploaded File: %+v\n", handler.Filename)
		fmt.Printf("File Size: %+v\n", handler.Size)
		fmt.Printf("MIME Header: %+v\n", handler.Header)

		monitor := r.URL.Query().Get("monitor")

		fmt.Printf("Monitor: %s\n", monitor)

		homeFolder := os.Getenv("HOME")
		tempFolder := fmt.Sprintf("%s/walls", homeFolder)

		tempFile, err := os.CreateTemp(tempFolder, "hyprPaperPlane_*-"+handler.Filename)

		if err != nil {
			fmt.Println(err)
		}

		filename := tempFile.Name()
		fmt.Println(filename)

		defer tempFile.Close()
		// read all of the contents of our uploaded file into a
		// byte array
		fileBytes, err := io.ReadAll(file)

		if err != nil {
			fmt.Println("ERROR")
			fmt.Println(err)
		} else {
			// write this byte array to our temporary file
			tempFile.Write(fileBytes)
			// return that we have successfully uploaded our file!
			fmt.Fprintf(w, "Successfully Uploaded File\n")
			defer readFromWeb(monitor, filename)
		}
	}
	mux.HandleFunc("POST /upload", uploadFile)

	mux.HandleFunc("GET /conf", handleConfig)
	mux.HandleFunc("GET /config", handleConfig)
	mux.HandleFunc("GET /configuration", handleConfig)
	mux.HandleFunc("GET /hyprpaper.conf", handleConfig)

	mux.HandleFunc("GET /json", handleJSON)

	server := http.Server{Addr: ":3000", Handler: mux}
	fmt.Println("Listening @ http://127.0.0.1:3000")
	server.ListenAndServe()
}
