from pathlib import Path
from typing import List

from ros_metrics_reporter.util import run_command_pipe


class Package:
    """
    Returns the package info
    """

    name: str
    ros_ws: Path
    path: Path
    type: str

    def __init__(self, name, git_ws, path, package_type):
        self.name = name
        self.git_ws = git_ws
        self.path = path
        self.type = package_type


class PackageInfo:
    """
    Provide a list of packages
    """

    ros_ws: Path
    package_list: List[Package]

    def __init__(self, ros_ws: Path):
        self.ros_ws = ros_ws.absolute()
        package_list = run_command_pipe(["colcon", "list"], cwd=ros_ws).splitlines()
        self.package_list = []
        for line in package_list:
            package_name, package_path, package_type = line.split()
            package_ros_ws = self.__find_git_ws(package_path)
            self.package_list.append(
                Package(package_name, Path(package_path), package_type)
            )

    def get_package_info(self, package_name: str) -> Package:
        for package in self.package_list:
            if package.name == package_name:
                return package
        return None

    def __iter__(self):
        return iter(self.package_list)

    def __find_git_ws(self, package_path: Path) -> Path:
        git_ws = Path(package_path).absolute()
        while git_ws != self.ros_ws:
            if (git_ws / ".git").is_dir():
                return git_ws
            git_ws = git_ws.parent
        raise ValueError(
            f"Cannot find .git directory. Package path: {package_path}, workspace: {ros_ws}"
        )
