class ImageCache {
    constructor() {
        this.cacheTime = 3 * 60 * 60 * 1000; // 3 hours in milliseconds
    }

    async getImage(url) {
        const cacheKey = this.getCacheKey(url);
        const cached = this.getFromCache(cacheKey);

        if (cached) {
            return cached;
        }

        try {
            const response = await fetch(url);
            const blob = await response.blob();
            const base64 = await this.blobToBase64(blob);
            
            this.saveToCache(cacheKey, base64);
            return base64;
        } catch (error) {
            console.error('Error loading image:', error);
            return url; // Fallback to original URL
        }
    }

    blobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }

    getCacheKey(url) {
        return btoa(url); // Base64 encode URL as cache key
    }

    getFromCache(key) {
        const cached = localStorage.getItem(key);
        if (!cached) return null;

        const { data, timestamp } = JSON.parse(cached);
        if (Date.now() - timestamp > this.cacheTime) {
            localStorage.removeItem(key);
            return null;
        }

        return data;
    }

    saveToCache(key, data) {
        const cacheData = {
            data,
            timestamp: Date.now()
        };
        try {
            localStorage.setItem(key, JSON.stringify(cacheData));
        } catch (e) {
            // If localStorage is full, clear old entries
            if (e.name === 'QuotaExceededError') {
                this.clearOldCache();
                localStorage.setItem(key, JSON.stringify(cacheData));
            }
        }
    }

    clearOldCache() {
        const now = Date.now();
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key.startsWith('img_')) {
                try {
                    const { timestamp } = JSON.parse(localStorage.getItem(key));
                    if (now - timestamp > this.cacheTime) {
                        localStorage.removeItem(key);
                    }
                } catch (e) {
                    localStorage.removeItem(key);
                }
            }
        }
    }

    clearCache() {
        for (let i = localStorage.length - 1; i >= 0; i--) {
            const key = localStorage.key(i);
            if (key.startsWith('img_')) {
                localStorage.removeItem(key);
            }
        }
    }
}

// Initialize image cache
const imageCache = new ImageCache();

// Function to update image sources with cached versions
async function updateImageSources() {
    const images = document.querySelectorAll('img[data-cache="true"]');
    
    for (const img of images) {
        const originalSrc = img.src;
        const cachedSrc = await imageCache.getImage(originalSrc);
        if (cachedSrc !== originalSrc) {
            img.src = cachedSrc;
        }
    }
}

// Add data-cache attribute to images that should be cached
document.addEventListener('DOMContentLoaded', () => {
    const images = document.querySelectorAll('.property-gallery img, .floorplan-container img');
    images.forEach(img => {
        img.setAttribute('data-cache', 'true');
    });
    
    updateImageSources();
}); 