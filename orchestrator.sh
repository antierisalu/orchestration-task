create_cluster() {
  vagrant up
  echo "cluster created"
}

start_cluster() {
  vagrant ssh master -c "sudo systemctl start k3s"
  vagrant ssh agent -c "sudo systemctl start k3s-agent"
  echo "cluster started"
}

stop_cluster() {
  vagrant ssh master -c "sudo systemctl stop k3s"
  vagrant ssh agent -c "sudo systemctl stop k3s-agent"
  vagrant halt
  echo "cluster stopped"
}

case "$1" in
  create)
    create_cluster
    ;;
  start)
    start_cluster
    ;;
  stop)
    stop_cluster
    ;;
  *)
    echo "Usage: $0 {create|start|stop}"
    exit 1
esac