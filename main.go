package main

import (
	"log"
	"net/http"
	"os/exec"

	"github.com/gorilla/mux"
)

func saveSnapshot(w http.ResponseWriter, r *http.Request) {
	cmd := exec.Command("/bin/bash", "./backup.sh")
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatal(err)
	}
	log.Print(string(out))
}

func listSnapshots(w http.ResponseWriter, r *http.Request) {
	cmd := exec.Command("/bin/bash", "./list.sh")
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatal(err)
	}
	log.Print(string(out))
}

func restoreSnapshot(w http.ResponseWriter, r *http.Request) {
	cmd := exec.Command("/bin/bash", "./restore.sh")
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatal(err)
	}
	log.Print(string(out))
}

func main() {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/backup", saveSnapshot)
	router.HandleFunc("/list", listSnapshots)
	router.HandleFunc("/restore", listSnapshots)
	log.Fatal(http.ListenAndServe(":8080", router))
}
