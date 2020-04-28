# Always prefer setuptools over distutils
from setuptools import setup, find_packages

setup(name='containizen',
      version='1.0.0',
      description='A program that produces a familiar, friendly greeting',
      python_requires='>=3.6',
      packages=find_packages(),
      entry_points={
          'console_scripts': [
              'main = hello_world.__main__:main'
          ]
      },

      # For an analysis of "install_requires" vs pip's requirements files see:
      # https://packaging.python.org/en/latest/requirements.html
      #install_requires=['peppercorn'],
)

