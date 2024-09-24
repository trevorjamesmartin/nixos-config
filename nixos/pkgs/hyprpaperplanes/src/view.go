package main

import (
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"os"
)

func jsonText() string {
	active, err := listActive()

	if err != nil {
		log.Fatal(err)
	}

	endComma := len(active) - 1
	multimon := endComma > 0

	var text string

	if multimon {
		text += `[`
	}

	for idx, p := range active {
		text += p.json()
		if multimon && idx < endComma {
			text += `,`
		}
	}

	if multimon {
		text += `]`
	}

	return text
}

func configText() string {
	var text string
	sources := make(map[string]bool)
	activeplanes, err := listActive()
	if err != nil {
		log.Fatal(err)
	}

	for _, p := range activeplanes {
		if preloaded, _ := sources[p.paper]; !preloaded {
			text += fmt.Sprintf("preload = %s\n", p.paper)
			sources[p.paper] = true
		}
	}

	for _, p := range activeplanes {
		text += fmt.Sprintf("wallpaper = %s,%s\n", p.monitor, p.paper)
	}
	text += "splash = false\n"
	return text
}

func hyperText() string {
	var hypertext string
	activeplanes, errListing := listActive()

	if errListing != nil {
		log.Fatal(errListing)
	}

	hypertext += fmt.Sprintf(`
	<!DOCTYPE html>
	<html>
	<head>
	<title>HyprPaperPlanes API %s</title>
	<style>
		* {
			background-color: black;
			color: white;
		}

		.formats {
			display: flex;
			justify-content: space-evenly;
		}
	</style>
	</head>
	<body>
		<div class="formats">
		<a href="/hyprpaper.conf">hyprpaper.conf</a>
		<a href="/json">JSON</a>
		</div>
	`, VERSION)

	for _, p := range activeplanes {
		bts, err := os.ReadFile(p.paper)

		if err != nil {
			log.Fatal(err)
		}

		data := fmt.Sprintf("data:%s;base64,%s",
			http.DetectContentType(bts),
			base64.StdEncoding.EncodeToString(bts))

		hypertext += fmt.Sprintf(`
		<div class="%s">%s</div>
		<style>
		.%s {
			line-height: 8rem; 
			text-align:center; 
			font-size: 4rem; 
			color: white; 
			width: 1280px; 
			height: 720px;
			margin-left: auto;
			margin-right: auto;
			margin-top: 80px;
			background-size: 1280px 720px; 
			background-image: url(%s);
			border: 4px solid white;
			border-radius: 12px;
		};
		</style>`, p.monitor, p.monitor, p.monitor, data)
	}

	hypertext += `</body></html>`
	return hypertext
}
