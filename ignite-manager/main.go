package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

var ips map[string]string = make(map[string]string)
var failed map[string]bool = make(map[string]bool)

type CreateRequest struct {
	Image string `json:"image"`
}
type CreateResponse struct {
	ID string `json:"id"`
}
type IPResponse struct {
	IP string `json:"ip_address"`
}

func main() {
	http.Handle("/create", Handler{createRequestHandler})
	http.Handle("/delete", Handler{deleteRequestHandler})
	http.Handle("/ip_address", Handler{ipAddressHandler})

	log.Fatal(http.ListenAndServe(":9090", nil))
}

func createRequestHandler(w http.ResponseWriter, r *http.Request) error {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return StatusError{500, err}
	}
	var req CreateRequest
	err = json.Unmarshal([]byte(body), &req)
	if err != nil {
		return StatusError{500, err}
	}
	vmID, err := Create(req.Image)
	if err != nil {
		return StatusError{500, err}
	}
	response, err := json.Marshal(&CreateResponse{ID: vmID})
	if err != nil {
		return StatusError{500, err}
	}
	w.Header().Add("Content-Type", "application/json")
	w.Write(response)
	go Start(vmID)
	return nil
}

func deleteRequestHandler(w http.ResponseWriter, r *http.Request) error {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return StatusError{500, err}
	}
	var req CreateResponse
	err = json.Unmarshal([]byte(body), &req)
	if err != nil {
		return StatusError{500, err}
	}
	err = Stop(req.ID)
	if err != nil {
		return StatusError{500, err}
	}
	w.Write([]byte{})
	return nil
}

func ipAddressHandler(w http.ResponseWriter, r *http.Request) error {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return StatusError{500, err}
	}
	var req CreateResponse
	err = json.Unmarshal([]byte(body), &req)
	if err != nil {
		return StatusError{500, err}
	}
	ip := ips[req.ID]
	if ip != "" {
		response, err := json.Marshal(&IPResponse{IP: ip})
		if err != nil {
			return StatusError{500, err}
		}
		w.Write([]byte(response))
		return nil
	}
	if failed[req.ID] {
		return StatusError{500, fmt.Errorf("Launch failed")}
	}
	return StatusError{404, fmt.Errorf("Not launched yet yet")}
}

func Create(imageName string) (string, error) {
	cmd := exec.Command("ignite", "create", "--log-level", "error", "--quiet", "--runtime", "docker", "--ssh", imageName)
	cmd.Stderr = os.Stderr
	vmIDBytes, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("Could not create VM: %s %s", err, string(vmIDBytes))
	}
	vmID := strings.TrimSpace(string(vmIDBytes))
	return vmID, nil
}

func Start(vmID string) {
	exec.Command("ignite", "start", vmID).Run()
	ip, err := getIP(vmID)
	if err != nil {
		failed[vmID] = true
	} else {
		ips[vmID] = ip
	}
}

func getIP(vmID string) (string, error) {
	cmd := exec.Command("ignite", "inspect", "vm", vmID, "-t", "{{.Status.Network.IPAddresses}}")
	maybeIP, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("Could not inspect VM: %s", err)
	}
	ip := strings.TrimSpace(string(maybeIP))
	if len(ip) == 0 {
		return "", fmt.Errorf("No IP assigned yet")
	}
	return ip, nil

}

func Stop(vmID string) error {
	cmd := exec.Command("ignite", "kill", vmID)
	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("Could not kill VM: %s", err)
	}
	return nil
}
