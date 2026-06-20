// PolyNova3D (version 3.3)
/***************************************************************
 Copyright (C) 1999 Novasoft Consulting

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Library General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU Library General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *****************************************************************/
#include "poly_nova.h"

#include <algorithm>

/* Third-party JSON library */
#include "cJSON.h"

extern "C" {
	int NetworkConnect();
	void NetworkDisconnect();
	char* PerformHTTPSRequest(const char* method, const char* path, const char* body);
}

void HighScoreHandler::init() {
	if (NetworkConnect() != 0) {
		logWarningMessage("Cannot connect to the network, check your network settings\n");
	} else {
		// Connected, try to refresh high scores from the server.
		this->loadOnlineScores();
		NetworkDisconnect();
	}
}

void HighScoreHandler::save() {
	if (online) {
		bool valid = true;

		if (localPlayerData.score < MIN_ONLINE_SCORE_VALUE) {
			std::string formattedNumber = formatStringWithCommas(MIN_ONLINE_SCORE_VALUE);
			logWarningMessage("Player high score must be greater than %s points to enable online saving\n", formattedNumber.c_str());
			valid = false;
		}

		if (localPlayerData.name == DEFAULT_PLAYER_NAME) {
			logWarningMessage("Cannot save Player high score online without a valid player name\n");
			valid = false;
		}

		if (valid) {
			if (NetworkConnect() != 0) {
				logWarningMessage("Cannot connect to the network, check your network settings\n");
			} else {
				// Connected.
				if (!playerToken) {
					// Player is not currently registered with the scoreboard.
					this->registerPlayer();

					// Update the high score data with the new token to keep in sync.
					if (playerToken) {
						for (size_t i = 0; i < highScores.size(); i++) {
							if (highScores[i].id == 0) {
								highScores[i].id = playerToken;
								break;
							}
						}
					}
				} else {
					// Update a registered player.
					this->syncRegisteredPlayer();
				}

				NetworkDisconnect();
			}
		}
	}

	this->savePlayerToken("token.dat");
	this->saveLocalPlayerData("local_player.dat");

	if (playerToken) {
		this->saveRegisteredPlayerData("registered_player.dat");
	}

	this->saveLocalScores("scores.dat");
}

void HighScoreHandler::loadOnlineScores() {
	logMessage("Trying to load the online high score data...\n");

	// Clear any existing data.
	highScores.clear();

	char get_path[128];
	snprintf(get_path, sizeof(get_path), "/api/%s/board/", API_TOKEN_READ);

	char* response = PerformHTTPSRequest("GET", get_path, NULL);
	if (response) {
		// Parse the response.
		cJSON* root = cJSON_Parse(response);
		if (root) {
			cJSON* players = cJSON_GetObjectItem(root, "players");
			if (cJSON_IsArray(players)) {
				int num_players = cJSON_GetArraySize(players);

				for (int i = 0; i < num_players; i++) {
					cJSON* p = cJSON_GetArrayItem(players, i);
					cJSON* id_obj = cJSON_GetObjectItem(p, "id");
					cJSON* name_obj = cJSON_GetObjectItem(p, "name");
					cJSON* score_obj = cJSON_GetObjectItem(p, "score");
					highScores.push_back(HighScoreData(id_obj->valueint, name_obj->valuestring, score_obj->valueint));
				}
			}

			cJSON_Delete(root);
		}

		free(response);
	}

	// See if was successful.
	if (highScores.empty()) {
		logWarningMessage("Could not load the online high score data\n");
	} else {
		logMessage("Loaded %d high scores\n", (int)highScores.size());
	}
}

void HighScoreHandler::registerPlayer() {
	logMessage("Trying to register player with the online scoreboard...\n");

	// Build the JSON body using cJSON
	cJSON *body_root = cJSON_CreateObject();
	if (body_root) {
		cJSON_AddStringToObject(body_root, "name", localPlayerData.name.c_str());
		cJSON_AddBoolToObject(body_root, "is_eliminated", false);
		cJSON_AddBoolToObject(body_root, "is_visible", true);
		cJSON_AddNullToObject(body_root, "text_color");
		cJSON_AddNullToObject(body_root, "background_color");
		cJSON_AddNullToObject(body_root, "profile_image");
		cJSON_AddNullToObject(body_root, "team");
		cJSON_AddNullToObject(body_root, "data");
		cJSON_AddNumberToObject(body_root, "score", localPlayerData.score);
		cJSON_AddNullToObject(body_root, "scores");
		cJSON_AddNumberToObject(body_root, "goal", 0);

		char *body_string = cJSON_PrintUnformatted(body_root);
		if (body_string) {
			char post_path[128];
			snprintf(post_path, sizeof(post_path), "/api/%s/player/", API_TOKEN_ADMIN);
			char* response = PerformHTTPSRequest("POST", post_path, body_string);
			if (response) {
				cJSON *response_root = cJSON_Parse(response);
				if (response_root) {
					// Get the "player" nested object
					cJSON *player = cJSON_GetObjectItemCaseSensitive(response_root, "player");

					// Get the "id" item from the player object
					if (cJSON_IsObject(player)) {
						cJSON *id_item = cJSON_GetObjectItemCaseSensitive(player, "id");
						if (cJSON_IsNumber(id_item)) {
							playerToken = id_item->valueint;
						}
					}

					cJSON_Delete(response_root);
				}
			}

			free(body_string);
		}

		cJSON_Delete(body_root);
	}

	// See if was successful.
	if (!playerToken) {
		logWarningMessage("Could not register player: %s\n", localPlayerData.name.c_str());
	} else {
		logMessage("Registered player: %s\n", localPlayerData.name.c_str());
		registeredPlayerData.name = localPlayerData.name;
		registeredPlayerData.score = localPlayerData.score;
	}
}

void HighScoreHandler::syncRegisteredPlayer() {
	logMessage("Trying to synchronise a registered player with the online scoreboard...\n");
	const char* successString = "\"success\":true}";

	if (localPlayerData.name != registeredPlayerData.name) {
		cJSON* body_root = cJSON_CreateObject();
		if (body_root) {
			cJSON_AddStringToObject(body_root, "name", localPlayerData.name.c_str());

			char *body_string = cJSON_PrintUnformatted(body_root);
			if (body_string) {
				char post_path[128];
				snprintf(post_path, sizeof(post_path), "/api/%s/player/%u", API_TOKEN_UPDATE, playerToken);

				char* response = PerformHTTPSRequest("PATCH", post_path, body_string);
				if (response) {
					if (strstr(response, successString) != nullptr) {
						logMessage("Player name synchronised with the server\n");
						registeredPlayerData.name = localPlayerData.name;
					}
				}

				free(body_string);
			}

			cJSON_Delete(body_root);
		}
	}

	if (localPlayerData.score > registeredPlayerData.score) {
		cJSON* body_root = cJSON_CreateObject();
		if (body_root) {
			cJSON_AddNumberToObject(body_root, "player_id", playerToken);
			cJSON_AddNumberToObject(body_root, "score", localPlayerData.score);
			cJSON_AddNumberToObject(body_root, "goal", 0);
			cJSON_AddStringToObject(body_root, "operation", "set");

			char *body_string = cJSON_PrintUnformatted(body_root);
			if (body_string) {
				char post_path[128];
				snprintf(post_path, sizeof(post_path), "/api/%s/score/", API_TOKEN_UPDATE);
				char* response = PerformHTTPSRequest("POST", post_path, body_string);
				if (response) {
					if (strstr(response, successString) != nullptr) {
						logMessage("Player score synchronised with the server\n");
						registeredPlayerData.score = localPlayerData.score;
					}
				}

				free(body_string);
			}

			cJSON_Delete(body_root);
		}
	}
}
