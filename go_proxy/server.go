package main

import (
	"context"
	"errors"
	"fmt"
	"github.com/google/go-github/github"
	"github.com/gorilla/mux"
	"github.com/gorilla/securecookie"
	"golang.org/x/oauth2"
	gh "golang.org/x/oauth2/github"
	"google.golang.org/api/compute/v1"
	"html/template"
	"io/ioutil"
	"log"
	"math/rand"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

var PORT = 9000
var GOTTY_PORTS = map[string]int{}
var COOKIE_NAME = "DebuggingSchoolUser"
var DOMAIN = "debugging-school-test.jvns.ca"
var BASE_DIR = "/var/school"
var INSTANCE_IMAGES = map[string]string{
	"deleted-file":      "packer-1558305868",
	"why-no-connection": "packer-1557938552",
	"write-write-write": "packer-1557803463",
	"cant-make-files":   "packer-1557859494",
}

var ALLOWED_USERS = map[string]bool{
	"jvns":         true,
	"kamalmarhubi": true,
}

var OAUTH_CONFIG = &oauth2.Config{
	ClientID:     "5dd3b91709f4de218599",
	ClientSecret: "b8e70ab317a574570ca41033e3ccece8e7205adb",
	Scopes:       []string{},
	Endpoint:     gh.Endpoint,
}

var hashKey = []byte("XbCHUhwyNtHLTCUU")
var blockKey = []byte("GkieAteXcMQwDgEm")
var s = securecookie.New(hashKey, blockKey)

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	rtr := mux.NewRouter()

	rtr.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))

	rtr.HandleFunc("/proxy/{instance}/{rest:.*}", func(w http.ResponseWriter, r *http.Request) {
		if _, err := LoginCheck(w, r); err != nil {
			return
		}
		vars := mux.Vars(r)
		instance := vars["instance"]
		rest := vars["rest"]
		gottyPort := StartGotty(instance)
		fmt.Printf("port is %d\n", gottyPort)
		path, err := url.Parse(fmt.Sprintf("http://127.0.0.1:%d/%s", gottyPort, rest))
		if err != nil {
			log.Fatal(err)
		}
		rp := httputil.NewSingleHostReverseProxy(path)
		rp.Director = func(r *http.Request) {
			r.URL = path
		}
		rp.ServeHTTP(w, r)
	})

	rtr.HandleFunc("/oauth-callback/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println(r.Body)
		ctx := context.Background()
		code := r.URL.Query().Get("code")
		tok, err := OAUTH_CONFIG.Exchange(ctx, code)
		if err != nil {
			log.Fatal(err)
		}
		ts := oauth2.StaticTokenSource(tok)
		tc := oauth2.NewClient(ctx, ts)
		client := github.NewClient(tc)
		user, _, err := client.Users.Get(ctx, "")
		if err != nil {
			w.WriteHeader(500)
			w.Write([]byte("failed to login"))
			return
		}
		if encoded, err := s.Encode(COOKIE_NAME, *user.Login); err == nil {
			cookie := &http.Cookie{
				Name:     COOKIE_NAME,
				Value:    encoded,
				Path:     "/",
				HttpOnly: true,
				Domain:   DOMAIN,
			}
			http.SetCookie(w, cookie)
			w.WriteHeader(200)
			w.Write([]byte(*user.Login))
		} else {
			log.Fatal(err)
		}
	})

	rtr.HandleFunc("/login/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-cache")
		login := template.Must(template.ParseFiles("templates/wrapper.html", "templates/login.html"))
		login.Execute(w, nil)
	})

	rtr.HandleFunc("/puzzles", func(w http.ResponseWriter, r *http.Request) {
		if _, err := LoginCheck(w, r); err != nil {
			return
		}
		w.Header().Set("Cache-Control", "no-cache")
		homepage := template.Must(template.ParseFiles("templates/wrapper.html", "templates/puzzles.html"))
		homepage.Execute(w, map[string]interface{}{
			"Puzzles": INSTANCE_IMAGES,
		})
	})

	rtr.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		DeleteOldInstances()
		w.Header().Set("Cache-Control", "no-cache")
		homepage := template.Must(template.ParseFiles("templates/wrapper.html", "templates/index.html"))
		homepage.Execute(w, nil)
	})

	rtr.HandleFunc("/github_login/", func(w http.ResponseWriter, r *http.Request) {
		// Redirect user to consent page to ask for permission
		// for the scopes specified above.
		url := OAUTH_CONFIG.AuthCodeURL("state", oauth2.AccessTypeOffline)
		http.Redirect(w, r, url, 302)
	})

	rtr.HandleFunc("/puzzle/{instance}", func(w http.ResponseWriter, r *http.Request) {
		if _, err := LoginCheck(w, r); err != nil {
			return
		}
		instance := mux.Vars(r)["instance"]

		err := CheckRunning(instance)
		if err != nil {
			w.Header().Set("Cache-Control", "no-cache")
			homepage := template.Must(template.ParseFiles("templates/wrapper.html", "templates/puzzle_not_up.html"))
			err := homepage.Execute(w, nil)
			if err != nil {
				log.Fatal(err)
			}
			return
		}

		data := struct {
			Instance string
		}{
			Instance: instance,
		}
		w.Header().Set("Cache-Control", "no-cache")
		puzzle := template.Must(template.ParseFiles("templates/puzzle.html"))
		err = puzzle.Execute(w, data)
		if err != nil {
			log.Fatal(err)
		}
	})

	rtr.HandleFunc("/admin/create-instance/{class}", func(w http.ResponseWriter, r *http.Request) {
		user, err := LoginCheck(w, r)
		if err != nil {
			return
		}
		class := mux.Vars(r)["class"]
		DeleteOldInstances()
		if NumInstances() > 10 {
			w.Header().Set("Cache-Control", "no-cache")
			w.WriteHeader(500)
			w.Write([]byte("too many instances"))
			return
		}
		name := GetOrCreateInstance(class, user)
		http.Redirect(w, r, fmt.Sprintf("http://%s/puzzle/%s", DOMAIN, name), 302)
	})

	rtr.HandleFunc("/admin/delete-old-instances", func(w http.ResponseWriter, r *http.Request) {
		DeleteOldInstances()
		w.Header().Set("Cache-Control", "no-cache")
		w.WriteHeader(200)
	})

	log.Println("Listening...")

	http.ListenAndServe(":8080", rtr)
}

func InstancesService() *compute.InstancesService {
	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	if err != nil {
		log.Fatal(err)
	}
	return compute.NewInstancesService(computeService)
}

func DeleteOldInstances() {
	instancesService := InstancesService()
	instances, err := instancesService.List("wizard-debugging-school", "us-east1-c").Do()
	if err != nil {
		log.Fatal(err)
	}

	for _, instance := range instances.Items {
		created, err := time.Parse(time.RFC3339, instance.CreationTimestamp)
		if err != nil {
			log.Fatal(err)
		}
		if time.Now().Sub(created) > 3*time.Hour {
			if contains(instance.Tags.Items, "puzzle") {
				fmt.Println("Deleting: ", instance.Name)
				_, err := instancesService.Delete("wizard-debugging-school", "us-east1-c", instance.Name).Do()
				if err != nil {
					log.Fatal(err)
				}
			}
		}
	}
}

func GetOrCreateInstance(class string, user string) string {
	if name := GetInstance(class, user); name != "" {
		return name
	} else {
		return CreateInstance(class, user)
	}
}

func GetInstance(class string, user string) string {
	instancesService := InstancesService()
	instances, err := instancesService.List("wizard-debugging-school", "us-east1-c").Do()
	if err != nil {
		log.Fatal(err)
	}

	for _, instance := range instances.Items {
		if contains(instance.Tags.Items, fmt.Sprintf("class-%s", class)) && contains(instance.Tags.Items, fmt.Sprintf("user-%s", user)) {
			return instance.Name
		}
	}
	return ""
}

func contains(items []string, item string) bool {
	for _, i := range items {
		if item == i {
			return true
		}
	}
	return false
}

func CreateInstance(class string, user string) string {
	instancesService := InstancesService()
	image := "projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20190514"
	user_data, err := ioutil.ReadFile(fmt.Sprintf("puzzles/%s/cloud-init.yaml", class))
	user_data_string := string(user_data)
	update_disabled := "update_disabled"
	if err != nil {
		log.Fatal("failed to read user data: ", err)
	}
	instance := compute.Instance{
		Name:        class + "-" + RandomString(6),
		MachineType: "https://www.googleapis.com/compute/v1/projects/wizard-debugging-school/zones/us-east1-c/machineTypes/f1-micro",
		Disks: []*compute.AttachedDisk{
			&compute.AttachedDisk{
				InitializeParams: &compute.AttachedDiskInitializeParams{
					SourceImage: image,
				},
				AutoDelete: true,
				Boot:       true,
			},
		},
		Metadata: &compute.Metadata{
			Items: []*compute.MetadataItems{
				&compute.MetadataItems{
					Key:   "cos-update-strategy",
					Value: &update_disabled,
				},
				&compute.MetadataItems{
					Key:   "user-data",
					Value: &user_data_string,
				},
			},
		},
		NetworkInterfaces: []*compute.NetworkInterface{
			&compute.NetworkInterface{
				AccessConfigs: []*compute.AccessConfig{},
			},
		},
		Tags: &compute.Tags{Items: []string{"puzzle", fmt.Sprintf("class-%s", class), fmt.Sprintf("user-%s", user)}},
	}
	operation, err := instancesService.Insert("wizard-debugging-school", "us-east1-c", &instance).Do()
	if err != nil {
		log.Fatal("couldn't create instance", err)
	}
	x := strings.Split(operation.TargetLink, "/")
	name := x[len(x)-1]
	fmt.Println("Created new instance:", name)
	return name
}

func NumInstances() int {
	instancesService := InstancesService()
	instances, err := instancesService.List("wizard-debugging-school", "us-east1-c").Do()
	if err != nil {
		log.Fatal(err)
	}
	return len(instances.Items)
}

func CheckRunning(instance string) error {
	cmd := exec.Command(
		"ssh",
		"-i", "wizard.key",
		"-o", "ConnectTimeout=1",
		"-o", "StrictHostKeyChecking=false",
		fmt.Sprintf("wizard@%s.us-east1-c.c.wizard-debugging-school.internal", instance),
		"sudo", "rm", "-f", "/etc/update-motd.d/*",
	)
	cmd.Start()
	return cmd.Wait()
}

func CachedGottyURI(instance string) (int, error) {
	port, ok := GOTTY_PORTS[instance]
	if !ok {
		return 0, errors.New("no gotty yet")
	}
	if !GottyUp(port) {
		return 0, errors.New("can't connect to gotty")
	}
	return port, nil
}

func GottyUp(port int) bool {
	path_url, err := url.Parse(fmt.Sprintf("http://127.0.0.1:%d", port))
	if err != nil {
		log.Fatal(err)
	}
	conn, err := net.Dial("tcp", path_url.Host)
	if err != nil {
		return false
	}
	defer conn.Close()
	return true
}

func StartGotty(instance string) int {
	port, err := CachedGottyURI(instance)
	if err == nil {
		return port
	} else {
		fmt.Println("no gotty, continuing: ", err)
	}
	PORT += 1
	port = PORT
	cmd := exec.Command(
		"ssh",
		"-i", "wizard.key",
		"-o", "ConnectTimeout=1",
		fmt.Sprintf("wizard@%s.us-east1-c.c.wizard-debugging-school.internal", instance),
		"bash",
		"/home/wizard/files/run.sh",
	)
	cmd.Start()
	cmd.Wait()
	cmd = exec.Command(
		"ssh",
		"-i", "wizard.key",
		"-o", "ConnectTimeout=1",
		fmt.Sprintf("wizard@%s.us-east1-c.c.wizard-debugging-school.internal", instance),
		"sudo rm -rf /home/wizard/files",
	)
	cmd.Start()
	cmd.Wait()
	cmd = exec.Command(
		filepath.Join(BASE_DIR, "gotty"),
		"--index", "gotty-index.html",
		"-w",
		"-p", fmt.Sprintf("%d", PORT),
		"ssh",
		"-i", "wizard.key",
		"-o", "ConnectTimeout=1",
		fmt.Sprintf("wizard@%s.us-east1-c.c.wizard-debugging-school.internal", instance),
	)
	GOTTY_PORTS[instance] = port
	cmd.Start()
	i := 0
	for !GottyUp(port) && i < 200 {
		i += 1
		time.Sleep(10 * time.Millisecond)
	}
	if !GottyUp(port) {
		log.Fatal("gotty failed to come up in 2 seconds")
	}
	return port
}

func RandomString(n int) string {
	var letter = []rune("abcdefghijklmnopqrstuvwxyz")

	b := make([]rune, n)
	for i := range b {
		b[i] = letter[rand.Intn(len(letter))]
	}
	return string(b)
}

func ProxyPath(instance string, path string, base string) string {
	gotty_resource := strings.TrimPrefix(path, fmt.Sprintf("/proxy/%s", instance))
	if gotty_resource == "" {
		gotty_resource = "/"
	}
	return fmt.Sprintf("%s%s", strings.TrimSuffix(base, "/"), gotty_resource)
}

func GetUser(r *http.Request) (*string, error) {
	if cookie, err := r.Cookie(COOKIE_NAME); err == nil {
		var value string
		if err = s.Decode(COOKIE_NAME, cookie.Value, &value); err == nil {
			return &value, nil
		} else {
			return nil, err
		}
	} else {
		return nil, err
	}
}

func LoginCheck(w http.ResponseWriter, r *http.Request) (string, error) {
	if r.Host == "localhost" {
		// make local development easier
		return "jvns", nil
	}
	user, err := GetUser(r)
	if err != nil {
		http.Redirect(w, r, fmt.Sprintf("http://%s/login", DOMAIN), 302)
		return "", err
	}
	allowed, ok := ALLOWED_USERS[*user]
	if allowed && ok {
		return *user, nil
	} else {
		w.WriteHeader(500)
		w.Write([]byte("you don't have permission to use the site yet!"))
	}
	return "", errors.New("no permission")
}
