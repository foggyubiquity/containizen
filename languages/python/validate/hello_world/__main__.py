# https://chriswarrick.com/blog/2014/09/15/python-apps-the-right-way-entry_points-and-scripts/
import sys

def main(args=None):
    if args is None:
        args = sys.argv[1:]
    print("Hello, world!")

if __name__ == "__main__":
    main()
