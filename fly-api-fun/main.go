package main

import (
	"fmt"
	"github.com/superfly/flyctl/api"
	"os"
)

func main() {
	appName := os.Args[1]

	token := os.Getenv("FLY_API_TOKEN")

	api.SetBaseURL("https://api.fly.io")
	client := api.NewClient(token, "0.0.171")
	orgs, err := client.GetOrganizations()
	if err != nil {
		fmt.Println("error getting organizations: %s", err)
		return
	}
	org := orgs[0]
	//err = client.DeleteApp(appName)
	//if err != nil {
	//	fmt.Println("error deleting app: %s", err)
	//}
	_, err = client.CreateApp(appName, org.ID)
	if err != nil {
		fmt.Println("error creating app: ", err)
	}

	var definition = map[string]interface{}{
		"services": []map[string]interface{}{
			map[string]interface{}{
				"internal_port": 23,
				"protocol":      "tcp",
				//"experimental": []map[string]interface{}{
				//	map[string]interface{}{
				//		"allowed_public_ports": []interface{}{22},
				//	},
				//},
				"ports": []api.PortHandler{api.PortHandler{Port: 10022}},
			},
		},
	}

	serverCfg, err := client.ParseConfig(appName, definition)
	if err != nil {
		fmt.Println("error setting config: ", err)
	}
	imageTag := "jvns/game:base"
	input := api.DeployImageInput{AppID: appName, Image: imageTag, Definition: &serverCfg.Definition}
	_, err = client.DeployImage(input)
	if err != nil {
		fmt.Println("error deploying image: ", err)
	}
	app, err := client.GetApp(appName)
	fmt.Println(app.IPAddresses.Nodes[0].Address)
}
