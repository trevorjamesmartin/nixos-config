package main

import (
	"fmt"
	"os"
)

const VERSION = "0.2"

func main() {
	argsWithoutProg := os.Args[1:]

	if len(argsWithoutProg) > 0 {

		switch argsWithoutProg[0] {

		case "-listen":
			api()
		case "--listen":
			api()
		case "-l":
			api()
		case "-json":
			fmt.Print(jsonText())
		case "-j":
			fmt.Print(jsonText())
		case "--json":
			fmt.Print(jsonText())
		case "--j":
			fmt.Print(jsonText())
		case "--html":
			fmt.Print(hyperText())
		default:
			readFromCLI(argsWithoutProg)
		}

	} else {
		fmt.Printf("hyprPaperPlanes %s", VERSION)
	}

}
