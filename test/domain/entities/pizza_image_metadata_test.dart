import 'package:flutter_test/flutter_test.dart';
import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';

void main() {
  // 1. OpenAI (DALL-E 3 / ChatGPT)
  test('should detect AI generation from OpenAI DALL-E 3 manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "DALL-E 3"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 2. Adobe (Firefly)
  test('should detect AI generation from Adobe Firefly manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Adobe Firefly", "version": "1.0"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 3. Microsoft (Designer / Bing Image Creator)
  test('should detect AI generation from Microsoft Designer manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Image Creator from Microsoft Designer"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 4. Meta (Imagine with Meta AI)
  test('should detect AI generation from Imagine with Meta AI manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Imagine with Meta AI"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 5. Google (Imagen 3 / SynthID / Gemini)
  test('should detect AI generation from Google Imagen/SynthID manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Google LLC"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                    "description": "Image generated with SynthID",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  test('should return false for authentic hardware camera manifest (e.g., Sony Alpha)', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Sony ILCE-9M3"}, // Sony Alpha 9 III
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/digitalCapture",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isFalse);
  });

  test('should return false for standard human editing (e.g., Photoshop color grading)', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.edited",
                    "softwareAgent": {"name": "Adobe Photoshop 2024"},
                    "description": "Color corrected and cropped",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isFalse);
  });

  test('should return false when c2paData is null or malformed', () {
    expect(const EmptyImageMetadata(c2paData: null).isC2paAiGenerated, isFalse);
    expect(EmptyImageMetadata(c2paData: {"manifests": "not-a-map"}).isC2paAiGenerated, isFalse);
  });

  // 6. Amazon (Titan Image Generator)
  // Amazon joined C2PA steering committee in Sept 2024.
  // Titan Image Generator embeds an invisible watermark and C2PA metadata.
  test('should detect AI generation from Amazon Titan Image Generator manifest', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "claim_generator_info": [
            {"name": "Amazon Titan Image Generator"}
          ],
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Amazon Titan Image Generator"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 7. OpenAI (ChatGPT) — multi-manifest structure
  // In ChatGPT/Sora manifests, the AI indicator lives in an ingredient
  // sub-manifest, NOT in the active manifest. This tests the core fix.
  test('should detect AI generation from ChatGPT multi-manifest structure (AI indicator in ingredient)', () {
    final manifestData = {
      "active_manifest": "urn:c2pa:f2521887-d7a6-4822-8f8e-db248e0a5b87",
      "manifests": {
        "urn:c2pa:f2521887-d7a6-4822-8f8e-db248e0a5b87": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {"action": "c2pa.opened"},
                ],
              },
            },
          ],
        },
        // The AI creation indicator is in this ingredient manifest, not the active one.
        "urn:c2pa:a203d892-586a-435f-a205-3ba3711b12cf": {
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "GPT-4o"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia",
                  },
                  {"action": "c2pa.converted"},
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isTrue);
  });

  // 8. Leica (hardware camera — negative case)
  // Leica M11-P was the first camera to ship with Content Credentials built-in.
  // Photos taken with it should NOT be flagged as AI-generated.
  test('should return false for authentic Leica M11-P camera capture', () {
    final manifestData = {
      "active_manifest": "active",
      "manifests": {
        "active": {
          "claim_generator_info": [
            {"name": "Leica M11-P"}
          ],
          "assertions": [
            {
              "label": "c2pa.actions.v2",
              "data": {
                "actions": [
                  {
                    "action": "c2pa.created",
                    "softwareAgent": {"name": "Leica M11-P"},
                    "digitalSourceType":
                        "http://cv.iptc.org/newscodes/digitalsourcetype/digitalCapture",
                  },
                ],
              },
            },
          ],
        },
      },
    };

    final metadata = EmptyImageMetadata(c2paData: manifestData);
    expect(metadata.isC2paAiGenerated, isFalse);
  });
}
