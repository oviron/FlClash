package main

import "os"

func handleDelFile(path string, result ActionResult) {
	go func() {
		fileInfo, err := os.Stat(path)
		if err != nil {
			if os.IsNotExist(err) {
				result.success("")
				return
			}
			result.error(err.Error())
			return
		}
		if fileInfo.IsDir() {
			err = os.RemoveAll(path)
		} else {
			err = os.Remove(path)
		}
		if err != nil {
			result.error(err.Error())
			return
		}
		result.success("")
	}()
}
