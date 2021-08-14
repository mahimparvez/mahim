{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "colab": {
      "name": "Torrent Downloader.ipynb",
      "provenance": [],
      "collapsed_sections": [],
      "include_colab_link": true
    },
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "codemirror_mode": {
        "name": "ipython",
        "version": 3
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3",
      "version": "3.7.4"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\"https://colab.research.google.com/github/PradyumnaKrishna/Colab-Hacks/blob/master/Torrent%20Downloader/Torrent%20Downloader.ipynb\" target=\"_parent\"><img src=\"https://colab.research.google.com/assets/colab-badge.svg\" alt=\"Open In Colab\"/></a>"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "aQuWDmfm9YOi"
      },
      "source": [
        "# Torrent Downloader\n",
        "Download & Store Files in Google Drive\n",
        "\n",
        "> **Note :** You can download any file and store it at google drive using command `wget <link>` and move it to the `/content/drive/My\\ Drive/` location \n",
        "<br> **Warning :** This notebook is against the Policy of Colab. Use it on your own risk\n"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "Uf90U73y9YOj"
      },
      "source": [
        "## Google Drive\n",
        "\n",
        "For Stream files into Drive"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "oWM9l2fvtuvO"
      },
      "source": [
        "from google.colab import drive\n",
        "drive.mount('/content/drive')"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "kuzLN8YSDBPU"
      },
      "source": [
        "## Import Libraries & Start Server"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "bxx1hyAnZh1h"
      },
      "source": [
        ""
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "MbxBwyNADAyl"
      },
      "source": [
        "# Install Dependency\n",
        "! pip install lbry-libtorrent\n",
        "\n",
        "# Libraries Import\n",
        "import time\n",
        "import ipywidgets as widgets\n",
        "import libtorrent as lt\n",
        "\n",
        "from threading import Thread\n",
        "from IPython.display import display, clear_output\n",
        "\n",
        "# Server Start\n",
        "ses = lt.session()\n",
        "ses.listen_on(6881, 6891)\n",
        "\n",
        "# Torrent States\n",
        "state_str = [\n",
        "    \"queued\",\n",
        "    \"checking\",\n",
        "    \"downloading metadata\",\n",
        "    \"downloading\",\n",
        "    \"finished\",\n",
        "    \"seeding\",\n",
        "    \"allocating\",\n",
        "    \"checking fastresume\",\n",
        "]"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "yvRYoOe0ca46"
      },
      "source": [
        "## Torrent Properties\n",
        "- Add Torrent\n",
        "- Remove Torrent"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "TYLT_c5dCpd0"
      },
      "source": [
        "downloads = []\n",
        "\n",
        "# Add Torrent\n",
        "def add_torrent():\n",
        "    params = {\"save_path\": \"/content/drive/My Drive/Torrent\"}\n",
        "    link = input(\"Enter Magnet Link or Torrent File URL: \")\n",
        "    downloads.append(\n",
        "        lt.add_magnet_uri(ses, link, params)\n",
        "    )\n",
        "\n",
        "# Remove Torrent\n",
        "def remove_torrent():\n",
        "    i = int(input(\"Enter your Choice : \"))\n",
        "    i-=1\n",
        "\n",
        "    for index, download in enumerate(downloads[:]):\n",
        "        if (index == i) :\n",
        "            ses.remove_torrent(download)\n",
        "            downloads.remove(download)\n",
        "            print(download.name(), \"Removed\")\n",
        "            break\n",
        "    else :\n",
        "        print(\"Torrent not found\")\n",
        "    time.sleep(2.5)\n",
        "\n",
        "# Torrent Speed\n",
        "def rate(val):\n",
        "    prefix = ['B', 'kB', 'MB', 'GB', 'TB']\n",
        "    for i in range(len(prefix)):\n",
        "        if abs(val) < 1000:\n",
        "            if i == 0:\n",
        "                return '%5.3g %s' % (val, prefix[i])\n",
        "            else:\n",
        "                return '%4.3g %s' % (val, prefix[i])\n",
        "        val /= 1000\n",
        "\n",
        "    return '%6.3g PB' % val"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "-P9t0qaNCaxQ"
      },
      "source": [
        "## Output Class"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "m_D1VrT1CbJi"
      },
      "source": [
        "class output:\n",
        "    def __init__(self):\n",
        "        self._running = True\n",
        "    \n",
        "    # Thread Killing\n",
        "    def kill(self):\n",
        "        self._running = False\n",
        "\n",
        "    # Print Status Bar\n",
        "    def show(self) :\n",
        "        layout = widgets.Layout(width=\"auto\")\n",
        "        style = {\"description_width\": \"initial\"}\n",
        "        download_bars = [\n",
        "            widgets.FloatSlider(\n",
        "                step=0.01, disabled=True, layout=layout, style=style\n",
        "            )\n",
        "            for _ in downloads\n",
        "        ]\n",
        "        display(*download_bars)\n",
        "\n",
        "        while self._running :\n",
        "            for index, download in enumerate(downloads[:]):\n",
        "                bar = download_bars[index]\n",
        "                s = download.status()\n",
        "                bar.value = s.progress * 100\n",
        "                bar.description = \" \".join(\n",
        "                    [\n",
        "                        str(index+1)+\". \\t\",\n",
        "                        download.name()[:25] +\n",
        "                        \"...\\t|\\t\",\n",
        "                        '%s/s | ' % rate(s.download_rate),\n",
        "                        '%s/s | ' % rate(s.upload_rate),\n",
        "                        '%s Done | ' % rate(s.total_done),\n",
        "                        state_str[s.state],\n",
        "                    ]\n",
        "                )\n",
        "            # time.sleep(1)"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "tqKcWHZcYRIA"
      },
      "source": [
        "## Main\n",
        "For Client and Managing Torrent"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "b09BxnANO2ep"
      },
      "source": [
        "def main() :\n",
        "    if downloads == []:\n",
        "        print(\"No Torrent Found, Please add one\")\n",
        "        add_torrent()\n",
        "\n",
        "    while True:\n",
        "        clear_output()\n",
        "        print(\"No  Torrent Name.    D.Speed U.Speed Downloaded  Status   Progress\")\n",
        "\n",
        "        bar = output()\n",
        "        printing = Thread(target=bar.show)\n",
        "        printing.start()\n",
        "\n",
        "        time.sleep(2)\n",
        "\n",
        "        print(\"[A] Add Torrent \\t\\t [R] Remove Torrent \\t\\t [Q] Quit\")\n",
        "        choice = input(\"Enter Choice : \")\n",
        "\n",
        "        if choice.lower() == 'a':\n",
        "            bar.kill()\n",
        "            add_torrent()\n",
        "\n",
        "        elif choice.lower() == 'r':\n",
        "            bar.kill()\n",
        "            remove_torrent()\n",
        "        \n",
        "        elif choice.lower() == 'q':\n",
        "            bar.kill()\n",
        "            print(\"Daemon Still Running\")\n",
        "            return\n",
        "\n",
        "        else :\n",
        "            bar.kill()\n",
        "            print(\"Wrong Choice\")\n",
        "\n",
        "if __name__ == \"__main__\" :\n",
        "    main()"
      ],
      "execution_count": null,
      "outputs": []
    }
  ]
}
