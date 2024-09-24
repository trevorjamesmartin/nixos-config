package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

const VERSION = "0.2"

type plane struct {
	monitor string
	paper   string
}

func (p *plane) json() string {
	return fmt.Sprintf(`{ "monitor": "%s", "paper": "%s" }`, p.monitor, p.paper)
}

func listActive() ([]*plane, error) {
	cmd := exec.Command("hyprctl", "hyprpaper", "listactive")
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		return nil, err
	}

	scanner := bufio.NewScanner(stdout)
	err = cmd.Start()

	if err != nil {
		return nil, err
	}

	var planes []*plane

	for scanner.Scan() {
		kv := strings.Split(scanner.Text(), "=")
		if len(kv) > 1 {
			planes = append(planes, &plane{monitor: strings.TrimSpace(kv[0]), paper: strings.TrimSpace(kv[1])})
		}
	}

	if scanner.Err() != nil {
		cmd.Process.Kill()
		cmd.Wait()
		return nil, scanner.Err()
	}

	return planes, nil
}

func jsonFu(activeplanes []*plane, fu func(a ...any) (n int, err error)) {
	endComma := len(activeplanes) - 1
	multimon := endComma > 0

	var text string

	if multimon {
		text += `[`
	}

	for idx, p := range activeplanes {
		text += p.json()
		if multimon && idx < endComma {
			text += `,`
		}
	}

	if multimon {
		text += `]`
	}

	fu(text)
}

func unloadWallpaper(image string) {
	fmt.Printf("unload: %s\n", image)
	cmd := exec.Command("hyprctl", "hyprpaper", "unload", image)
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		log.Fatal(err)
		return
	}

	scanner := bufio.NewScanner(stdout)
	err = cmd.Start()

	if err != nil {
		log.Fatal(err)
	}

	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}

	if scanner.Err() != nil {
		cmd.Process.Kill()
		cmd.Wait()
		log.Fatal(scanner.Err())
		return
	}

}

func preloadWallpaper(image string) {
	fmt.Printf("preload: %s\n", image)

	cmd := exec.Command("hyprctl", "hyprpaper", "preload", image)
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		log.Fatal(err)
		return
	}

	scanner := bufio.NewScanner(stdout)
	err = cmd.Start()

	if err != nil {
		log.Fatal(err)
	}

	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}

	if scanner.Err() != nil {
		cmd.Process.Kill()
		cmd.Wait()
		log.Fatal(scanner.Err())
		return
	}

}

func setWallpaper(image string, monitor string) {
	fmt.Printf("set wallpaper: %s,'%s'\n", monitor, image)

	cmd := exec.Command("hyprctl", "hyprpaper", "wallpaper", fmt.Sprintf("%s,%s", monitor, image))
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		log.Fatal(err)
		return
	}

	scanner := bufio.NewScanner(stdout)
	err = cmd.Start()

	if err != nil {
		log.Fatal(err)
	}

	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}

	if scanner.Err() != nil {
		cmd.Process.Kill()
		cmd.Wait()
		log.Fatal(scanner.Err())
		return
	}

}

func configText() string {
	var text string
	sources := make(map[string]bool)
	activeplanes, err := listActive()
	if err != nil {
		log.Fatal(err)
	}

	for i, p := range activeplanes {
		if i < 1 {
			if preloaded, _ := sources[p.paper]; !preloaded {
				text += fmt.Sprintf("preload = %s\n", p.paper)
				sources[p.paper] = true
			}
		}
	}

	for i, p := range activeplanes {
		if i < 1 {
			text += fmt.Sprintf("wallpaper = %s,%s\n", p.monitor, p.paper)
		}
	}
	text += "splash = false\n"
	return text
}

func updateConfig() {
	base := os.Getenv("HOME")

	configfile := fmt.Sprintf("%s/.config/hypr/hyprpaper.conf", base)

	fmt.Println("update config")
	// remove old file if it exists
	if errRemoving := os.Remove(configfile); errRemoving != nil {
		fmt.Println(errRemoving)
	}

	// create new
	f, err := os.Create(configfile)
	if err != nil {
		log.Fatal(err)
	}

	defer f.Close()

	defer fmt.Println("ok")

	fmt.Fprint(f, configText())
}

func activeMonitor() string {
	buf, err := exec.Command("hyprctl", "activeworkspace", "-j").CombinedOutput()

	if err != nil {
		fmt.Println(err)
		return ""
	}

	Map := make(map[string]string)
	err = json.Unmarshal(buf, &Map)
	monitor := Map["monitor"]
	return string(monitor)
}

func main() {
	argsWithoutProg := os.Args[1:]

	if len(argsWithoutProg) > 0 {
		activeplanes, err := listActive()

		if err != nil {
			fmt.Println(err)
			return
		}

		switch argsWithoutProg[0] {

		case "-listen":
			api()
		case "--listen":
			api()
		case "-l":
			api()
		case "-json":
			jsonFu(activeplanes, fmt.Print)
		case "-j":
			jsonFu(activeplanes, fmt.Print)
		case "--json":
			jsonFu(activeplanes, fmt.Print)
		case "--j":
			jsonFu(activeplanes, fmt.Print)
		case "--html":
			fmt.Print(hyperText())
		default:
			// path to wallpaper ?
			_, err := os.Stat(argsWithoutProg[0])
			if os.IsNotExist(err) {
				fmt.Println("not a valid background image")
			} else {
				// file exists
				nextImage := argsWithoutProg[0]

				monitor := activeMonitor()

				var prevImage string

				for _, p := range activeplanes {
					if p.monitor == monitor {
						prevImage = p.paper
						break
					}
				}

				if prevImage != nextImage {
					unloadWallpaper(prevImage)
					preloadWallpaper(nextImage)
					setWallpaper(nextImage, monitor)
					updateConfig()
				}
			}
		}

	}

	if len(argsWithoutProg) == 0 {
		fmt.Printf("hyprPaperPlanes %s", VERSION)
	}

}
