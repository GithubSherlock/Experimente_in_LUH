import cv2
import numpy as np
from copy import deepcopy
from matplotlib import pyplot as plt

from . import Algorithm


class InvisCloak (Algorithm):

    """ init function """
    def __init__(self):
        self.flagRGB = False
        self.flagHSV = False
        self.imgstack = list()

        self.background = None
        self.get_background = True  # To activate the "magic cloak" or not
        self.save_img = False

        pass

    """ Processes the input image"""
    def process(self, img):

        """ 2.1 Vorverarbeitung """
        """ 2.1.1 Rauschreduktion """
        plotNoise = False   # Schaltet die Rauschvisualisierung ein
        if plotNoise:
            self._plotNoise(img, "Rauschen vor Korrektur")
        img = self._211_Rauschreduktion(img)
        if plotNoise:
            self._plotNoise(img, "Rauschen nach Korrektur")
        """ 2.1.2 HistogrammSpreizung """
        img = self._212_HistogrammSpreizung(img)


        """ 2.2 Farbanalyse """
        """ 2.2.1 RGB """
        self._221_RGB(img)
        """ 2.2.2 HSV """
        self._222_HSV(img)



        """ 2.3 Segmentierung und Bildmdifikation """
        img = self._23_SegmentUndBildmodifizierung(img)

        return img

    """ Reacts on mouse callbacks """
    def mouse_callback(self, event, x, y, flags, param):
        if event == cv2.EVENT_LBUTTONUP:
            self.flagRGB = True
            self.flagHSV = True
            self.save_img = True
            print("A Mouse click happend! at position", x, y)

    def _plotNoise(self, img, name:str):
        height, width = np.array(img.shape[:2])
        centY = (height / 2).astype(int)
        centX = (width / 2).astype(int)

        cutOut = 5
        tmpImg = deepcopy(img)
        tmpImg = tmpImg[centY - cutOut:centY + cutOut, centX - cutOut:centX + cutOut, :]

        outSize = 500
        tmpImg = cv2.resize(tmpImg, (outSize, outSize), interpolation=cv2.INTER_NEAREST)

        cv2.imshow(name, tmpImg)
        cv2.waitKey(1)

    def _211_Rauschreduktion(self, img):
        """
            Hier steht Ihr Code zu Aufgabe 2.1.1 (Rauschunterdrückung)
            - Implementierung Mittelwertbildung über N Frames
        """
        frame_number = 1  # frame_number is N in mathematical formular
        self.imgstack.append(np.copy(img))
        if len(self.imgstack) > frame_number:
            self.imgstack.pop(0)
        img = np.mean(self.imgstack,axis=0)
        img = img.astype(np.uint8)

        return img


    def _212_HistogrammSpreizung(self, img):
        """
            Hier steht Ihr Code zu Aufgabe 2.1.2 (Histogrammspreizung)
            - Transformation HSV
            - Histogrammspreizung berechnen
            - Transformation BGR
        """
        img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img = img.astype(float)
        v = img[:, :, 2]
        v = (v - np.min(v))*255/(np.max(v)-np.min(v))
        img[:, :, 2] = v
        img = img.astype(np.uint8)
        img = cv2.cvtColor(img, cv2.COLOR_HSV2BGR)

        return img

    def _221_RGB(self, img):
        """
            Hier steht Ihr Code zu Aufgabe 2.2.1 (RGB)
            - Histogrammberechnung und Analyse
        """
        if self.flagRGB:
            self.flagRGB = False
            #cv2.waitKey(3000)  # wait 3 second
            # set size and range
            hist_size = 256
            hist_range = [0, 256]
            # [0:B, 1:G, 2:R]
            histr_b = cv2.calcHist([img], [0], None, [hist_size], hist_range)
            histr_g = cv2.calcHist([img], [1], None, [hist_size], hist_range)
            histr_r = cv2.calcHist([img], [2], None, [hist_size], hist_range)

            '''plot figure'''
            fig1, ax1 = plt.subplots(2, 2, figsize=(8, 8))
            #  R
            ax1[0, 0].plot(histr_b, color="b")
            ax1[0, 0].set_title("B Channel")
            ax1[0, 0].set_xlim([0, 256])

            #  G
            ax1[1, 0].plot(histr_g, color="g")
            ax1[1, 0].set_title("G Channel")
            ax1[1, 0].set_xlim([0, 256])

            #  R
            ax1[0, 1].plot(histr_r, color="r")
            ax1[0, 1].set_title("R Channel")
            ax1[0, 1].set_xlim([0, 256])

            #  photo
            ax1[1, 1].imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
            ax1[1, 1].set_title("RGB-Image")

            #  set size
            plt.subplots_adjust(wspace=0.4)
            fig1.tight_layout()
            path_str = "./figure/Histogramm_RGB_magic.png"  # ohne oder mit oder magic
            fig1.savefig(path_str)
            fig1.show()
            pass

    def _222_HSV(self, img):
        """
            Hier steht Ihr Code zu Aufgabe 2.2.2 (HSV)
            - Histogrammberechnung und Analyse im HSV-Raum
        """
        if self.flagHSV:
            self.flagHSV = False
            #cv2.waitKey(3000)  # wait 3 second
            # transform BGR image to HSV image
            img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

            # set size and range
            hist_size = 256
            hist_range = [0, 256]
            # [0:H, 1:S, 2:V]
            histr_h = cv2.calcHist([img_hsv], [0], None, [hist_size], hist_range)
            histr_s = cv2.calcHist([img_hsv], [1], None, [hist_size], hist_range)
            histr_v = cv2.calcHist([img_hsv], [2], None, [hist_size], hist_range)

            '''plot figure'''
            fig2, ax2 = plt.subplots(2, 2, figsize=(8, 8))
            #  H
            ax2[0, 0].plot(histr_h, color="b")
            ax2[0, 0].set_title("H Channel")
            ax2[0, 0].set_xlim([0, 256])

            #  S
            ax2[1, 0].plot(histr_s, color="g")
            ax2[1, 0].set_title("S Channel")
            ax2[1, 0].set_xlim([0, 256])

            #  V
            ax2[0, 1].plot(histr_v, color="r")
            ax2[0, 1].set_title("V Channel")
            ax2[0, 1].set_xlim([0, 256])

            #  photo
            ax2[1, 1].imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))  # cv2.COLOR_BGR2HSV
            ax2[1, 1].set_title("RGB-Image")

            #  set size
            plt.subplots_adjust(wspace=0.4)
            fig2.tight_layout()
            path_str = "./figure/Histogramm_HSV_magic.png"  # ohne oder mit oder magic
            fig2.savefig(path_str)
            fig2.show()
            pass

    def _23_SegmentUndBildmodifizierung (self, img):
        """
            Hier steht Ihr Code zu Aufgabe 2.3.1 (StatischesSchwellwertverfahren)
            Implementieren Sie die von Ihnen gefundene Regel nach Gleichung 5, um eine Bin¨armaske zu erhalten. Sie k¨onnen die Randbedingungen wie im folgenden Code-
Schnipsel 7 implementieren.Geben Sie die gefundene Bin¨armaske als Ausgangsbild auf dem Bildschirm aus. Sollten die gefundenen Wertebereich zu keinen sinnvollen Segmentierungen f¨uhren, d¨urfen Sie Gleichung 5 selbstverst¨andlich anpassen!
Implementieren Sie ebenfalls eine Mausklick-Funktion, mit der Sie das aktuelle Bild und die dazugeh¨orige Bin¨armaske abspeichern k¨onnen. F¨ur das Abspeichern von Bildern k¨onnen Sie die Funktion cv2.imwrite(img, ”path to store.png”) verwenden.
Aufgabe 1 Geben Sie Ihren Code an und beschreiben Sie ihn. Geben Sie nur relevante Code Bereiche an! Geben Sie ebenfalls das aufgenommene Bild sowie die dazu-
geh¨orige Bin¨armaske an.
            - Binärmaske erstellen
        """
        img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        # H condition1
        low_h = 30
        high_h = 180
        is_condition_1_true = (low_h < img_hsv[:, :, 0]) * (img_hsv[:, :, 0] < high_h)

        # S condition2
        # low_s = 0
        # high_s = 25
        # is_condition_2_true = (low_s < img_hsv[:, :, 1]) * (img_hsv[:, :, 1] < high_s)

        # V condition3
        low_v = 50
        high_v = 160
        is_condition_2_true = (low_v < img_hsv[:, :, 2]) * (img_hsv[:, :, 2] < high_v)

        binary_mask = is_condition_1_true * is_condition_2_true
        # kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
        # kernel = np.array([[1,1,1],
        #                    [1,1,1],
        #                    [1,1,1]])
        # binary_mask = cv2.dilate(binary_mask, kernel=kernel, iterations=5)

        """
            Hier steht Ihr Code zu Aufgabe 2.3.2 (Binärmaske)
            - Binärmaske optimieren mit Opening/Closing
            - Wahl größte zusammenhängende Region
        """
        binary_mask = np.uint8(binary_mask) * 255
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
        binary_mask = cv2.dilate(binary_mask, kernel=kernel, iterations=5)
        (cnts, _) = cv2.findContours(binary_mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        mask = np.zeros_like(img[:, :, 0])
        if cnts:
            c = max(cnts, key=cv2.contourArea)  # key is area
            mask = cv2.drawContours(mask, [c], -1, color=255, thickness=-1)
        else:
            pass

        # kernel = np.array([[1,1,1],
        #                    [1,1,1],
        #                    [1,1,1]])

        """
            Hier steht Ihr Code zu Aufgabe 2.3.1 (Bildmodifizerung)
            - Hintergrund mit Mausklick definieren
            - Ersetzen des Hintergrundes
        """
        if self.get_background:  # get Background
            self.background = img
            self.get_background = False
        if np.array(self.background).any():
            img = cv2.bitwise_and(img, img, mask=cv2.bitwise_not(mask))
            img2 = cv2.bitwise_and(self.background, self.background, mask=mask)
            img = cv2.add(img, img2)
        if self.save_img:
            cv2.imwrite("./figure/Magic_magic.png", img)  # ohne oder mit oder magic
            self.save_img = False

        return img
