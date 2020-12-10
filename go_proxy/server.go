package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

func readMapping() map[string]int {
    resp, err := http.Get("http://localhost:3000/running_instances")
    if err != nil {
        log.Fatal(err)
    }
    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	var mapping map[string]int
	json.Unmarshal(body, &mapping)
	return mapping
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	rtr := mux.NewRouter()

	rtr.HandleFunc("/proxy/{gotty_id}/{rest:.*}", func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		gotty_id := vars["gotty_id"]
		rest := vars["rest"]
		mapping := readMapping()
		gottyPort, ok := mapping[gotty_id]
		if !ok {
			w.WriteHeader(500)
			w.Write([]byte("no instance"))
			return
		}
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

	log.Println("Listening...")

	err := http.ListenAndServe(":8080", rtr)
	if err != nil {
		log.Fatal(err)
	}
}
